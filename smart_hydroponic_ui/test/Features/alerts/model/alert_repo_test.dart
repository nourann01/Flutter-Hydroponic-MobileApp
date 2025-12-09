import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockSqliteService mockSqliteService;
  late MockSensorStateMgmt mockSensorStateMgmt;
  late MockDatabase mockDatabase;
  late AlertsRepository repository;

  setUp(() {
    mockSqliteService = MockSqliteService();
    mockSensorStateMgmt = MockSensorStateMgmt();
    mockDatabase = MockDatabase();

    when(mockSqliteService.database).thenAnswer((_) async => mockDatabase);

    repository = AlertsRepository(
      sqliteService: mockSqliteService,
      sensorStateMgmt: mockSensorStateMgmt,
    );
  });

  test('getUnreadCount returns correct value', () async {
    when(
      mockDatabase.rawQuery(
        'SELECT COUNT(*) as count FROM alerts WHERE isRead = 0',
      ),
    ).thenAnswer(
      (_) async => [
        {'count': 3},
      ],
    );

    final count = await repository.getUnreadCount();

    expect(count, 3);
    verify(
      mockDatabase.rawQuery(
        'SELECT COUNT(*) as count FROM alerts WHERE isRead = 0',
      ),
    ).called(1);
  });

  test('markAsRead calls database update', () async {
    when(
      mockDatabase.update(
        'alerts',
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [1],
      ),
    ).thenAnswer((_) async => 1);

    await repository.markAsRead(1);

    verify(
      mockDatabase.update(
        'alerts',
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [1],
      ),
    ).called(1);
  });

  test('getAllAlerts returns list of Alert objects', () async {
    final alertMap = {
      'id': 1,
      'sensorType': 'temperature',
      'previousStatus': 'normal',
      'currentStatus': 'warning',
      'sensorValue': 50.0,
      'message': 'Temperature changed',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': 0,
    };

    when(
      mockDatabase.query('alerts', orderBy: 'timestamp DESC'),
    ).thenAnswer((_) async => [alertMap]);

    final alerts = await repository.getAllAlerts();

    expect(alerts.length, 1);
    expect(alerts.first.sensorType, 'temperature');
    expect(alerts.first.currentStatus, 'warning');
  });
}
