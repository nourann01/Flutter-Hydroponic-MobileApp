import 'package:flutter_test/flutter_test.dart';
import 'package:smart_hydroponic_ui/Features/Sensors/model/sensor_model.dart';

void main() {
  group('Sensor Model Tests', () {
    test('Sensor object should be created correctly', () {
      final sensor = Sensor(
        id: 1,
        sensorType: 'Temperature',
        value: 25.7,
        status: 'OK',
        timestamp: '2025-12-08',
      );

      expect(sensor.id, 1);
      expect(sensor.sensorType, 'Temperature');
      expect(sensor.value, 25.7);
      expect(sensor.status, 'OK');
      expect(sensor.timestamp, '2025-12-08');
    });

    test('toMap should convert Sensor to Map correctly', () {
      final sensor = Sensor(
        id: 5,
        sensorType: 'Humidity',
        value: 40.5,
        status: 'Normal',
        timestamp: '2025-12-08 12:00',
      );

      final map = sensor.toMap();

      expect(map['id'], 5);
      expect(map['sensorType'], 'Humidity');
      expect(map['value'], 40.5);
      expect(map['status'], 'Normal');
      expect(map['timestamp'], '2025-12-08 12:00');
    });

    test('fromMap should convert Map to Sensor correctly', () {
      final map = {
        'id': 10,
        'sensorType': 'Soil',
        'value': '55.2', // testing string number
        'status': 'Active',
        'timestamp': '2025-12-08 13:00',
      };

      final sensor = Sensor.fromMap(map);

      expect(sensor.id, 10);
      expect(sensor.sensorType, 'Soil');
      expect(sensor.value, 55.2); // parsed correctly
      expect(sensor.status, 'Active');
      expect(sensor.timestamp, '2025-12-08 13:00');
    });

    test('fromMap should handle invalid or missing value safely', () {
      final map = {
        'sensorType': 'Light',
        'value': 'abc', // invalid double
        'status': 'Error',
        'timestamp': 'now',
      };

      final sensor = Sensor.fromMap(map);

      // Should fallback to 0.0 safely
      expect(sensor.value, 0.0);
    });

    test('copyWith should update fields correctly', () {
      final sensor = Sensor(
        sensorType: 'Temperature',
        value: 30.0,
        status: 'OK',
        timestamp: '2025-12-08',
      );

      final updated = sensor.copyWith(value: 33.5, status: 'Warning');

      // Updated fields
      expect(updated.value, 33.5);
      expect(updated.status, 'Warning');

      // Unchanged fields
      expect(updated.sensorType, 'Temperature');
      expect(updated.timestamp, '2025-12-08');
    });

    test('copyWith should not modify original object', () {
      final sensor = Sensor(
        sensorType: 'Humidity',
        value: 70.0,
        status: 'OK',
        timestamp: '2025-12-08',
      );

      final updated = sensor.copyWith(value: 72.2);

      // New object changed
      expect(updated.value, 72.2);

      // Original stays same
      expect(sensor.value, 70.0);
    });
  });
}
