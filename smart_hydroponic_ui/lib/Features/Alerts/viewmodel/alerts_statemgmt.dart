import 'dart:async';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class AlertsStateMgmt extends ChangeNotifier {
  final AlertsRepository repository;

  AlertsStateMgmt({required this.repository}) {
    _initializeAlerts();
  }

  List<Alert> alerts = [];
  bool isLoading = true;
  String? errorMessage;
  Timer? _refreshTimer;

  Future<void> _initializeAlerts() async {
    // // Reset alerts table to ensure correct schema
    // await repository.sqliteService.resetAlertsTable();

    // Load alerts
    await _loadAlerts();

    // Start monitoring sensor status changes
    repository.monitorSensorStatusChanges();

    // Refresh alerts periodically
    _startPeriodicRefresh();
  }

  Future<void> _loadAlerts() async {
    print("AlertsStateMgmt: Loading alerts from SQLite...");
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      alerts = await repository.getAllAlerts();
      isLoading = false;
      errorMessage = null;
      print("AlertsStateMgmt: Loaded ${alerts.length} alerts");
      notifyListeners();
    } catch (error) {
      print("AlertsStateMgmt: Error loading alerts → $error");
      isLoading = false;
      errorMessage = "Failed to load alerts: $error";
      notifyListeners();
    }
  }

  // Refresh alerts periodically (every 5 seconds)
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadAlerts();
    });
  }

  // Get unread alerts count
  int get unreadCount => alerts.where((alert) => !alert.isRead).length;

  // Get alerts by severity
  List<Alert> getAlertsBySeverity(String status) {
    return alerts.where((alert) => alert.currentStatus == status).toList();
  }

  // Mark alert as read
  Future<void> markAsRead(int alertId) async {
    await repository.markAsRead(alertId);
    // Update local state
    final index = alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      alerts[index] = alerts[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Refresh alerts manually
  Future<void> refresh() async {
    await _loadAlerts();
  }

  // Insert dummy alerts for testing UI
  Future<void> insertDummyAlerts() async {
    final now = DateTime.now();

    final dummyAlerts = [
      Alert(
        sensorType: 'Temperature',
        previousStatus: 'Normal',
        currentStatus: 'Danger',
        sensorValue: 35.5,
        message: 'Temperature changed from Normal to Danger (Value: 35.50°C)',
        timestamp: now.subtract(const Duration(minutes: 5)).toIso8601String(),
        isRead: false,
      ),
      Alert(
        sensorType: 'Humidity',
        previousStatus: 'Normal',
        currentStatus: 'Warning',
        sensorValue: 75.2,
        message: 'Humidity changed from Normal to Warning (Value: 75.20%)',
        timestamp: now.subtract(const Duration(minutes: 15)).toIso8601String(),
        isRead: false,
      ),
      Alert(
        sensorType: 'Water Level',
        previousStatus: 'Warning',
        currentStatus: 'Normal',
        sensorValue: 80.0,
        message: 'Water Level changed from Warning to Normal (Value: 80.00%)',
        timestamp: now.subtract(const Duration(hours: 1)).toIso8601String(),
        isRead: true,
      ),
      Alert(
        sensorType: 'Light Intensity',
        previousStatus: 'Normal',
        currentStatus: 'Unknown',
        sensorValue: 0.0,
        message:
            'Light Intensity changed from Normal to Unknown (Value: 0.00 Lux)',
        timestamp: now.subtract(const Duration(hours: 2)).toIso8601String(),
        isRead: true,
      ),
    ];

    for (var alert in dummyAlerts) {
      await repository.sqliteService.insertAlert(alert.toMap());
    }

    await _loadAlerts();
    print('Dummy alerts inserted successfully');
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
