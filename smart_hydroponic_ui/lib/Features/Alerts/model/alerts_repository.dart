import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class AlertsRepository {
  final SqliteService sqliteService;
  final SensorStateMgmt sensorStateMgmt;

  AlertsRepository({
    required this.sqliteService,
    required this.sensorStateMgmt,
  });

  // Track previous sensor statuses to detect changes
  final Map<String, String> _previousStatuses = {};

  // Monitor sensor status changes and create alerts
  void monitorSensorStatusChanges() {
    sensorStateMgmt.addListener(() {
      for (var sensor in sensorStateMgmt.sensors) {
        final previousStatus = _previousStatuses[sensor.sensorType];
        final currentStatus = sensor.status;

        // Check if status has changed
        if (previousStatus != null && previousStatus != currentStatus) {
          _createAlert(
            sensorType: sensor.sensorType,
            previousStatus: previousStatus,
            currentStatus: currentStatus,
            sensorValue: sensor.value,
          );
        }

        // Update the tracked status
        _previousStatuses[sensor.sensorType] = currentStatus;
      }
    });
  }

  // Create and save an alert
  Future<void> _createAlert({
    required String sensorType,
    required String previousStatus,
    required String currentStatus,
    required double sensorValue,
  }) async {
    final message = _generateAlertMessage(
      sensorType,
      previousStatus,
      currentStatus,
      sensorValue,
    );

    final alert = Alert(
      sensorType: sensorType,
      previousStatus: previousStatus,
      currentStatus: currentStatus,
      sensorValue: sensorValue,
      message: message,
      timestamp: DateTime.now().toIso8601String(),
    );

    await sqliteService.insertAlert(alert.toMap());
    print('Alert created: ${alert.title} - $message');
  }

  // Generate alert message based on status change
  String _generateAlertMessage(
    String sensorType,
    String previousStatus,
    String currentStatus,
    double value,
  ) {
    return '$sensorType changed from $previousStatus to $currentStatus (Value: ${value.toStringAsFixed(2)})';
  }

  // Get all alerts from SQLite
  Future<List<Alert>> getAllAlerts() async {
    try {
      final db = await sqliteService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'alerts',
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => Alert.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }

  // Get alerts by severity
  Future<List<Alert>> getAlertsBySeverity(String severity) async {
    try {
      final allAlerts = await getAllAlerts();
      return allAlerts.where((alert) => alert.severity == severity).toList();
    } catch (e) {
      print('Error fetching alerts by severity: $e');
      return [];
    }
  }

  // Mark alert as read
  Future<void> markAsRead(int alertId) async {
    try {
      final db = await sqliteService.database;
      await db.update(
        'alerts',
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [alertId],
      );
      print('Alert $alertId marked as read');
    } catch (e) {
      print('Error marking alert as read: $e');
    }
  }

  // Get unread alerts count
  Future<int> getUnreadCount() async {
    try {
      final db = await sqliteService.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM alerts WHERE isRead = 0',
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
