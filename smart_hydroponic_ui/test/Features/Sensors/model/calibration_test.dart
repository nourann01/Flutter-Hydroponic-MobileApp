import 'package:flutter_test/flutter_test.dart';
import 'package:smart_hydroponic_ui/Features/Sensors/model/calibration_model.dart';

void main() {
  group('SensorCalibration model', () {
    test('can be instantiated with correct values', () {
      final calibration = SensorCalibration(sensorType: 'pH', offset: 0.5);

      expect(calibration.sensorType, 'pH');
      expect(calibration.offset, 0.5);
    });

    test('can update values', () {
      final calibration = SensorCalibration(sensorType: 'EC', offset: 1.0);

      // Update values
      calibration.sensorType = 'pH';
      calibration.offset = 0.7;

      expect(calibration.sensorType, 'pH');
      expect(calibration.offset, 0.7);
    });

    test('two instances with same values are equal if compared manually', () {
      final cal1 = SensorCalibration(sensorType: 'pH', offset: 0.5);
      final cal2 = SensorCalibration(sensorType: 'pH', offset: 0.5);

      // By default, these are different instances, so equality check fails
      expect(cal1.sensorType, cal2.sensorType);
      expect(cal1.offset, cal2.offset);
    });
  });
}
