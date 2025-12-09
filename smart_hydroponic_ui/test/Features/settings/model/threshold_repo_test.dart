import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late ThresholdRepository repository;
  late MockFirebaseService mockFirebase;

  setUp(() {
    mockFirebase = MockFirebaseService();
    repository = ThresholdRepository(firebaseService: mockFirebase);
  });

  group('ThresholdRepository Tests', () {
    test('saveThreshold calls firebase writeThresholdData', () async {
      final threshold = SensorThreshold(
        sensorType: 'Temperature',
        minValue: 10.0,
        maxValue: 30.0,
      );

      when(mockFirebase.writeThresholdData(any)).thenAnswer((_) async => null);

      await repository.saveThreshold(threshold);

      verify(mockFirebase.writeThresholdData(threshold.toMap())).called(1);
    });
  });
}
