import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockSensorRepository mockRepository;
  late SensorStateMgmt viewModel;

  setUp(() {
    mockRepository = MockSensorRepository();
    SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences
  });

  group('SensorStateMgmt', () {
    test('initializes with loading state and listens to sensors', () async {
      // Arrange
      final sensors = [
        Sensor(
          sensorType: 'pH',
          value: 7.0,
          status: 'Normal',
          timestamp: 'now',
        ),
      ];

      when(
        mockRepository.listenToAllSensors(),
      ).thenAnswer((_) => Stream.value(sensors));

      // Stub the history call which is triggered after sensors update
      when(mockRepository.getSensorHistory(any)).thenAnswer((_) async => []);

      // Act
      viewModel = SensorStateMgmt(repository: mockRepository);

      // Assert
      expect(viewModel.isLoading, true); // Initially true

      // Wait for stream to emit
      await Future.delayed(Duration.zero);

      expect(viewModel.isLoading, false);
      expect(viewModel.sensors, sensors);
      expect(viewModel.errorMessage, isNull);
    });

    test('handles error from repository stream', () async {
      // Arrange
      when(
        mockRepository.listenToAllSensors(),
      ).thenAnswer((_) => Stream.error('Firebase Error'));

      // Act
      viewModel = SensorStateMgmt(repository: mockRepository);

      // Wait for stream to emit error
      await Future.delayed(Duration.zero);

      // Assert
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, contains('Firebase Error'));
      expect(viewModel.sensors, isEmpty);
    });

    test('updateSensorReading applies calibration', () async {
      // Arrange
      final sensors = [
        Sensor(
          sensorType: 'pH',
          value: 7.0,
          status: 'Normal',
          timestamp: 'now',
        ),
      ];
      when(
        mockRepository.listenToAllSensors(),
      ).thenAnswer((_) => Stream.value(sensors));
      when(mockRepository.getSensorHistory(any)).thenAnswer((_) async => []);

      viewModel = SensorStateMgmt(repository: mockRepository);
      await Future.delayed(Duration.zero);

      // Set calibration
      final calibration = SensorCalibration(sensorType: 'pH', offset: 0.5);
      await viewModel.setCalibration(calibration);

      viewModel.updateSensorReading('pH', 7.0);

      // Assert
      final ph = viewModel.sensors.firstWhere((s) => s.sensorType == 'pH');
      expect(ph.value, 7.5); // 7.0 + 0.5
    });
  });
}
