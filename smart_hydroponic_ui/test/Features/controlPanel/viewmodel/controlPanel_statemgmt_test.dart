import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late ControlPanelStateMgmt stateMgmt;
  late MockControlPanelRepository mockRepository;
  late MockDatabaseEvent mockEvent;
  late MockDataSnapshot mockSnapshot;

  setUp(() {
    mockRepository = MockControlPanelRepository();
    stateMgmt = ControlPanelStateMgmt(repository: mockRepository);

    mockEvent = MockDatabaseEvent();
    mockSnapshot = MockDataSnapshot();
  });

  group('ControlPanelStateMgmt', () {
    test('init subscribes to actuators and updates state', () async {
      // Prepare mock snapshot
      when(mockSnapshot.value).thenReturn({
        'actuatorType': 'waterPump',
        'isOn': true,
        'intensity': 0.5,
        'timestamp': '2025-12-08T00:00:00Z',
      });
      when(mockEvent.snapshot).thenReturn(mockSnapshot);

      // Prepare repository streams
      when(
        mockRepository.listenToActuator(any),
      ).thenAnswer((_) => Stream.value(mockEvent));

      stateMgmt.init();

      await Future.delayed(Duration.zero);

      expect(stateMgmt.waterPump.isOn, true);
      expect(stateMgmt.waterPump.intensity, 0.5);
    });

    test('toggleWaterPump calls repository with updated actuator', () async {
      await stateMgmt.toggleWaterPump();
      expect(stateMgmt.waterPump.isOn, false);
      verify(mockRepository.sendActuatorCommand(stateMgmt.waterPump)).called(1);
    });

    test(
      'setWaterPumpIntensity updates intensity and calls repository',
      () async {
        await stateMgmt.setWaterPumpIntensity(0.8);
        expect(stateMgmt.waterPump.intensity, 0.8);
        verify(
          mockRepository.sendActuatorCommand(stateMgmt.waterPump),
        ).called(1);
      },
    );

    test(
      'emergencyStop turns off all actuators and calls repository',
      () async {
        await stateMgmt.emergencyStop();
        expect(stateMgmt.waterPump.isOn, false);
        expect(stateMgmt.lights.isOn, false);
        expect(stateMgmt.nutrientPump.isOn, false);
        verify(mockRepository.emergencyStop(any)).called(1);
      },
    );

    test('saveScheduledTask calls repository when inputs are set', () async {
      stateMgmt.setTaskType('waterPump');
      stateMgmt.setScheduledTime(TimeOfDay(hour: 12, minute: 30));
      stateMgmt.setScheduledIntensity(0.7);
      stateMgmt.setScheduledIsOn(true);

      await stateMgmt.saveScheduledTask();

      verify(mockRepository.addScheduledTask(any)).called(1);
    });

    test('resetScheduleInputs resets all scheduling fields', () {
      stateMgmt.setTaskType('waterPump');
      stateMgmt.setScheduledTime(TimeOfDay(hour: 12, minute: 30));
      stateMgmt.setScheduledIntensity(0.7);
      stateMgmt.setScheduledIsOn(false);

      stateMgmt.resetScheduleInputs();

      expect(stateMgmt.selectedTaskType, '');
      expect(stateMgmt.selectedTime, null);
      expect(stateMgmt.scheduledIntensity, 1.0);
      expect(stateMgmt.scheduledIsOn, true);
    });
  });
}
