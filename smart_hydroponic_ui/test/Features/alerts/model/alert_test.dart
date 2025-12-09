import 'package:flutter_test/flutter_test.dart';
import 'package:smart_hydroponic_ui/Features/Alerts/model/alert_model.dart';

void main() {
  group('Alert Model Tests', () {
    test('toMap() should convert Alert to Map correctly', () {
      final alert = Alert(
        id: 1,
        sensorType: 'Temperature',
        previousStatus: 'normal',
        currentStatus: 'danger',
        sensorValue: 85.5,
        message: 'Temperature exceeded safe limit',
        timestamp: '2024-12-08 10:00:00',
        isRead: true,
      );

      final map = alert.toMap();

      expect(map['id'], 1);
      expect(map['sensorType'], 'Temperature');
      expect(map['previousStatus'], 'normal');
      expect(map['currentStatus'], 'danger');
      expect(map['sensorValue'], 85.5);
      expect(map['message'], 'Temperature exceeded safe limit');
      expect(map['timestamp'], '2024-12-08 10:00:00');
      expect(map['isRead'], 1);
    });

    test('fromMap() should create Alert correctly', () {
      final map = {
        'id': 2,
        'sensorType': 'Humidity',
        'previousStatus': 'warning',
        'currentStatus': 'normal',
        'sensorValue': '45.0',
        'message': 'Humidity is back to normal',
        'timestamp': '2024-12-08 11:00:00',
        'isRead': 0,
      };

      final alert = Alert.fromMap(map);

      expect(alert.id, 2);
      expect(alert.sensorType, 'Humidity');
      expect(alert.previousStatus, 'warning');
      expect(alert.currentStatus, 'normal');
      expect(alert.sensorValue, 45.0);
      expect(alert.message, 'Humidity is back to normal');
      expect(alert.timestamp, '2024-12-08 11:00:00');
      expect(alert.isRead, false);
    });

    test('severity getter should return correct severity', () {
      expect(
        Alert(
          sensorType: 'Temp',
          previousStatus: 'normal',
          currentStatus: 'danger',
          sensorValue: 90,
          message: '',
          timestamp: '',
        ).severity,
        'danger',
      );

      expect(
        Alert(
          sensorType: 'Temp',
          previousStatus: 'warning',
          currentStatus: 'warning',
          sensorValue: 60,
          message: '',
          timestamp: '',
        ).severity,
        'warning',
      );

      expect(
        Alert(
          sensorType: 'Temp',
          previousStatus: 'danger',
          currentStatus: 'normal',
          sensorValue: 30,
          message: '',
          timestamp: '',
        ).severity,
        'info',
      );
    });

    test('copyWith() should return updated Alert object', () {
      final alert = Alert(
        id: 3,
        sensorType: 'Gas',
        previousStatus: 'normal',
        currentStatus: 'warning',
        sensorValue: 70,
        message: 'Gas leak detected',
        timestamp: '2024-12-08 12:00:00',
      );

      final updated = alert.copyWith(
        currentStatus: 'danger',
        sensorValue: 99.9,
        isRead: true,
      );

      expect(updated.id, 3);
      expect(updated.sensorType, 'Gas');
      expect(updated.previousStatus, 'normal');
      expect(updated.currentStatus, 'danger');
      expect(updated.sensorValue, 99.9);
      expect(updated.isRead, true);

      // ensure immutability
      expect(alert.currentStatus, 'warning');
      expect(alert.sensorValue, 70);
    });
  });
}
