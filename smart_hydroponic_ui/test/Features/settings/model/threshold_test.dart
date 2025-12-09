import 'package:flutter_test/flutter_test.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

void main() {
  group('SensorThreshold Model Tests', () {
    test('constructor initializes correctly', () {
      final threshold = SensorThreshold(
        sensorType: 'Temperature',
        minValue: 10.0,
        maxValue: 30.0,
      );

      expect(threshold.sensorType, 'Temperature');
      expect(threshold.minValue, 10.0);
      expect(threshold.maxValue, 30.0);
    });

    test('toMap returns correct map', () {
      final threshold = SensorThreshold(
        sensorType: 'Humidity',
        minValue: 20.0,
        maxValue: 60.0,
      );

      final map = threshold.toMap();

      expect(map['sensorType'], 'Humidity');
      expect(map['minValue'], 20.0);
      expect(map['maxValue'], 60.0);
    });

    test('fromMap creates correct object', () {
      final map = {'sensorType': 'Water Level', 'minValue': 5, 'maxValue': 15};

      final threshold = SensorThreshold.fromMap(map);

      expect(threshold.sensorType, 'Water Level');
      expect(threshold.minValue, 5.0);
      expect(threshold.maxValue, 15.0);
    });

    test('toMap and fromMap produce identical object', () {
      final original = SensorThreshold(
        sensorType: 'Light',
        minValue: 100.0,
        maxValue: 900.0,
      );

      final map = original.toMap();
      final reconstructed = SensorThreshold.fromMap(map);

      expect(reconstructed.sensorType, original.sensorType);
      expect(reconstructed.minValue, original.minValue);
      expect(reconstructed.maxValue, original.maxValue);
    });
  });
}
