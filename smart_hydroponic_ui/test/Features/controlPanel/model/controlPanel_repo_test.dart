import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockFirebaseService mockFirebaseService;
  late MockSqliteService mockSqliteService;
  late ControlPanelRepository repository;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    mockSqliteService = MockSqliteService();
    repository = ControlPanelRepository(
      firebaseService: mockFirebaseService,
      sqliteService: mockSqliteService,
    );
  });

  group('ControlPanelRepository', () {
    test('listenToActuator returns firebase stream', () {
      final stream =
          Stream<DatabaseEvent>.empty(); // <- specify type explicitly
      when(
        mockFirebaseService.listenToFirebaseNode('actuators/pump'),
      ).thenAnswer((_) => stream);

      final result = repository.listenToActuator('pump');
      expect(result, stream);
    });

    test(
      'sendActuatorCommand sends data to firebase and logs locally',
      () async {
        final actuator = Actuator(
          actuatorType: 'pump',
          intensity: 0.8,
          isOn: true,
          timestamp: DateTime.now().toString(),
        );

        when(
          mockFirebaseService.writeActuatorData(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockSqliteService.insertActuatorLog(any),
        ).thenAnswer((_) async => Future.value());

        await repository.sendActuatorCommand(actuator);

        verify(mockFirebaseService.writeActuatorData(any)).called(1);
        verify(mockSqliteService.insertActuatorLog(any)).called(1);
      },
    );

    test('getActuatorHistory fetches data from SQLite', () async {
      final logMap = {
        'actuatorType': 'pump',
        'intensity': 1.0,
        'status': 1,
        'timestamp': 'now',
      };
      when(
        mockSqliteService.getActuatorLogs('pump'),
      ).thenAnswer((_) async => [logMap]);

      final result = await repository.getActuatorHistory('pump');

      expect(result.length, 1);
      expect(result.first.actuatorType, 'pump');
      expect(result.first.isOn, true);
    });

    test('emergencyStop turns all actuators off', () async {
      final actuator = Actuator(
        actuatorType: 'pump',
        intensity: 0.5,
        isOn: true,
        timestamp: 'old',
      );

      when(
        mockFirebaseService.writeActuatorData(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockSqliteService.insertActuatorLog(any),
      ).thenAnswer((_) async => Future.value());

      await repository.emergencyStop([actuator]);

      expect(actuator.isOn, false);
      verify(mockFirebaseService.writeActuatorData(any)).called(1);
      verify(mockSqliteService.insertActuatorLog(any)).called(1);
    });

    test('addScheduledTask inserts task into SQLite', () async {
      final task = ScheduledTask(
        taskType: 'water',
        scheduledTime: 'now',
        status: 'pending',
      );

      when(
        mockSqliteService.insertScheduledTask(any),
      ).thenAnswer((_) async => Future.value());

      await repository.addScheduledTask(task);

      verify(mockSqliteService.insertScheduledTask(any)).called(1);
    });
  });
}
