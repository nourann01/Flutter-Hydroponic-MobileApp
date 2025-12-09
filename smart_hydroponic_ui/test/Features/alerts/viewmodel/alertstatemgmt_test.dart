import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockAlertsRepository mockRepository;
  late AlertsStateMgmt stateMgmt;

  final testAlerts = [
    Alert(
      id: 1,
      sensorType: 'Temperature',
      previousStatus: 'Normal',
      currentStatus: 'Danger',
      sensorValue: 35.5,
      message: 'Temp high',
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
    ),
    Alert(
      id: 2,
      sensorType: 'Humidity',
      previousStatus: 'Normal',
      currentStatus: 'Warning',
      sensorValue: 75.2,
      message: 'Humidity high',
      timestamp: DateTime.now().toIso8601String(),
      isRead: true,
    ),
  ];

  setUp(() {
    mockRepository = MockAlertsRepository();

    // Stub getAllAlerts() to return testAlerts
    when(mockRepository.getAllAlerts()).thenAnswer((_) async => testAlerts);

    // Stub monitorSensorStatusChanges() (void method)
    when(mockRepository.monitorSensorStatusChanges()).thenReturn(null);

    stateMgmt = AlertsStateMgmt(repository: mockRepository);
  });

  test('initialization loads alerts and sets isLoading to false', () async {
    // Wait a bit for _initializeAlerts to complete
    await Future.delayed(Duration(milliseconds: 100));

    expect(stateMgmt.isLoading, false);
    expect(stateMgmt.alerts.length, 2);
    verify(mockRepository.getAllAlerts()).called(1);
    verify(mockRepository.monitorSensorStatusChanges()).called(1);
  });

  test('unreadCount returns correct number of unread alerts', () async {
    await Future.delayed(Duration(milliseconds: 100));
    expect(stateMgmt.unreadCount, 1);
  });

  test('getAlertsBySeverity filters alerts correctly', () async {
    await Future.delayed(Duration(milliseconds: 100));
    // Add severity field to testAlerts if needed; assuming currentStatus as severity
    final dangerAlerts = stateMgmt.getAlertsBySeverity('Danger');
    expect(dangerAlerts.length, 1);
    expect(dangerAlerts.first.sensorType, 'Temperature');
  });

  test('markAsRead updates local alert and calls repository', () async {
    await Future.delayed(Duration(milliseconds: 100));

    when(mockRepository.markAsRead(1)).thenAnswer((_) async => null);

    await stateMgmt.markAsRead(1);

    expect(stateMgmt.alerts.first.isRead, true);
    verify(mockRepository.markAsRead(1)).called(1);
  });

  test('refresh calls _loadAlerts and updates state', () async {
    await Future.delayed(Duration(milliseconds: 100));

    await stateMgmt.refresh();

    expect(stateMgmt.alerts.length, 2);
    verify(mockRepository.getAllAlerts()).called(greaterThan(1));
  });
}
