import 'package:flutter_test/flutter_test.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

void main() {
  group('Actuator model', () {
    test('can be instantiated and fields are correct', () {
      final actuator = Actuator(
        id: 1,
        actuatorType: 'Pump',
        intensity: 0.8,
        isOn: true,
        timestamp: '2025-12-08T00:00:00Z',
      );

      expect(actuator.id, 1);
      expect(actuator.actuatorType, 'Pump');
      expect(actuator.intensity, 0.8);
      expect(actuator.isOn, true);
      expect(actuator.timestamp, '2025-12-08T00:00:00Z');
    });

    test('toMap converts correctly', () {
      final actuator = Actuator(
        id: 1,
        actuatorType: 'Pump',
        intensity: 0.8,
        isOn: true,
        timestamp: '2025-12-08T00:00:00Z',
      );

      final map = actuator.toMap();
      expect(map['id'], 1);
      expect(map['actuatorType'], 'Pump');
      expect(map['intensity'], 0.8);
      expect(map['status'], 1);
      expect(map['timestamp'], '2025-12-08T00:00:00Z');
    });

    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'actuatorType': 'Pump',
        'intensity': 0.8,
        'status': 1,
        'timestamp': '2025-12-08T00:00:00Z',
      };

      final actuator = Actuator.fromMap(map);
      expect(actuator.id, 1);
      expect(actuator.actuatorType, 'Pump');
      expect(actuator.intensity, 0.8);
      expect(actuator.isOn, true);
      expect(actuator.timestamp, '2025-12-08T00:00:00Z');
    });

    test('fromFirebase creates correct instance', () {
      final map = {
        'actuatorType': 'Pump',
        'intensity': 0.5,
        'isOn': false,
        'timestamp': '2025-12-08T00:00:00Z',
      };

      final actuator = Actuator.fromFirebase(map);
      expect(actuator.actuatorType, 'Pump');
      expect(actuator.intensity, 0.5);
      expect(actuator.isOn, false);
      expect(actuator.timestamp, '2025-12-08T00:00:00Z');
      expect(actuator.id, null);
    });
  });

  group('ScheduledTask model', () {
    test('can be instantiated and fields are correct', () {
      final task = ScheduledTask(
        id: 1,
        taskType: 'Watering',
        parameters: '2 liters',
        scheduledTime: '2025-12-08T06:00:00Z',
        status: 'Pending',
        intensity: 0.7,
        isOn: true,
      );

      expect(task.id, 1);
      expect(task.taskType, 'Watering');
      expect(task.parameters, '2 liters');
      expect(task.scheduledTime, '2025-12-08T06:00:00Z');
      expect(task.status, 'Pending');
      expect(task.intensity, 0.7);
      expect(task.isOn, true);
    });

    test('toMap converts correctly', () {
      final task = ScheduledTask(
        id: 1,
        taskType: 'Watering',
        parameters: '2 liters',
        scheduledTime: '2025-12-08T06:00:00Z',
        status: 'Pending',
        intensity: 0.7,
        isOn: true,
      );

      final map = task.toMap();
      expect(map['id'], 1);
      expect(map['taskType'], 'Watering');
      expect(map['parameters'], '2 liters');
      expect(map['scheduledTime'], '2025-12-08T06:00:00Z');
      expect(map['status'], 'Pending');
      expect(map['intensity'], 0.7);
      expect(map['isOn'], 1);
    });

    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'taskType': 'Watering',
        'parameters': '2 liters',
        'scheduledTime': '2025-12-08T06:00:00Z',
        'status': 'Pending',
        'intensity': 0.7,
        'isOn': 1,
      };

      final task = ScheduledTask.fromMap(map);
      expect(task.id, 1);
      expect(task.taskType, 'Watering');
      expect(task.parameters, '2 liters');
      expect(task.scheduledTime, '2025-12-08T06:00:00Z');
      expect(task.status, 'Pending');
      expect(task.intensity, 0.7);
      expect(task.isOn, true);
    });
  });
}
