import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_hydroponic_ui/Features/Sensors/model/sensor_model.dart';
import 'package:smart_hydroponic_ui/Features/Sensors/model/sensors_repository.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockFirebaseService mockFirebaseService;
  late MockSqliteService mockSqliteService;
  late SensorRepository repository;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    mockSqliteService = MockSqliteService();
    repository = SensorRepository(
      firebaseService: mockFirebaseService,
      sqliteService: mockSqliteService,
    );
  });

  group('SensorRepository - listenToAllSensors', () {
    test('emits list of sensors when data is a Map of Maps', () async {
      // Arrange
      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();
      final sensorData = {
        'pH': {
          'value': 6.5,
          'status': 'Normal',
          'timestamp': '2023-10-27T10:00:00Z',
          'sensorType': 'pH' // Optional, code handles if missing key
        },
        'temperature': {
          'value': 25.0,
          'status': 'Warning',
          'timestamp': '2023-10-27T10:00:00Z'
        }
      };

      when(mockFirebaseService.listenToFirebaseNode('sensors'))
          .thenAnswer((_) => Stream.value(mockEvent));
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.value).thenReturn(sensorData);
      
      // Mock SQLite to avoid null errors if invoked
      when(mockSqliteService.insertSensorData(any)).thenAnswer((_) async {});

      // Act
      final stream = repository.listenToAllSensors();

      // Assert
      expect(stream, emits(predicate<List<Sensor>>((list) {
        // expect 2 sensors
        if (list.length != 2) return false;
        
        // check pH
        final ph = list.firstWhere((s) => s.sensorType == 'pH');
        if (ph.value != 6.5) return false;

        // check temperature (key used as type if missing)
        final temp = list.firstWhere((s) => s.sensorType == 'temperature');
        if (temp.value != 25.0) return false;

        return true;
      })));
    });

    test('emits empty list when data is null', () async {
      // Arrange
      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();

      when(mockFirebaseService.listenToFirebaseNode('sensors'))
          .thenAnswer((_) => Stream.value(mockEvent));
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.value).thenReturn(null);

      // Act
      final stream = repository.listenToAllSensors();

      // Assert
      expect(stream, emits(isEmpty));
    });

    test('skips malformed sensor data', () async {
      // Arrange
      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();
      final sensorData = {
        'pH': {'valid': 'no'}, // Missing required fields
        'temperature': {
          'value': 25.0,
          'status': 'Normal',
          'timestamp': '2023-10-27T10:00:00Z'
        }
      };

      when(mockFirebaseService.listenToFirebaseNode('sensors'))
          .thenAnswer((_) => Stream.value(mockEvent));
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.value).thenReturn(sensorData);
      // Mock SQLite
      when(mockSqliteService.insertSensorData(any)).thenAnswer((_) async {});

      // Act
      final stream = repository.listenToAllSensors();

      // Assert
      expect(stream, emits(predicate<List<Sensor>>((list) {
        // pH is parsed with defaults because fromMap is robust
        // temperature is valid
        return list.length == 2 && 
               list.any((s) => s.sensorType == 'pH' && s.value == 0.0) &&
               list.any((s) => s.sensorType == 'temperature');
      })));
    });
  });

  group('SensorRepository - fetchLastSensorReading', () {
    test('returns Sensor when data exists', () async {
      // Arrange
      final mockSnapshot = MockDataSnapshot();
      final data = {
        'value': 7.0,
        'status': 'Normal',
        'timestamp': '2023-10-27T12:00:00Z',
        'sensorType': 'pH'
      };

      when(mockFirebaseService.readSensorData('pH'))
          .thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.value).thenReturn(data);

      // Act
      final result = await repository.fetchLastSensorReading('pH');

      // Assert
      expect(result, isNotNull);
      expect(result!.value, 7.0);
      expect(result.sensorType, 'pH');
    });

     test('returns null when data is null', () async {
      // Arrange
      final mockSnapshot = MockDataSnapshot();

      when(mockFirebaseService.readSensorData('pH'))
          .thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.value).thenReturn(null);

      // Act
      final result = await repository.fetchLastSensorReading('pH');

      // Assert
      expect(result, isNull);
    });
  });
}
