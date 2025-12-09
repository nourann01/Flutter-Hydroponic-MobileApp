import 'dart:io';
import 'dart:async';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class DashboardStateMgmt extends ChangeNotifier {
  final SensorStateMgmt? sensorStateMgmt;
  final SettingsStateMgmt? settingsStateMgmt;

  DashboardStateMgmt({this.sensorStateMgmt, this.settingsStateMgmt}) {
    _checkInitialConnectivity();
    _listenToFirebaseConnection();
    _startPeriodicConnectivityCheck();
    _initializeSystemMode();
  }

  // Connection Status
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  // System Mode
  bool _isAutomatic = true;
  bool get isAutomatic => _isAutomatic;

  StreamSubscription? _firebaseConnectionSubscription;
  StreamSubscription? _systemModeSubscription;
  Timer? _connectivityCheckTimer;

  // Initialize System Mode
  Future<void> _initializeSystemMode() async {
    // 1. Load from local DB first for instant UI
    final savedMode = await SqliteService.instance.getSystemSetting(
      'isAutomatic',
    );
    if (savedMode != null) {
      _isAutomatic = savedMode == 'true';
      notifyListeners();
    }

    // 2. Listen to Firebase for updates
    _systemModeSubscription = FirebaseService().listenToSystemMode().listen((
      event,
    ) {
      final value = event.snapshot.value;
      if (value != null) {
        final newMode = value as bool;
        if (_isAutomatic != newMode) {
          _isAutomatic = newMode;
          // Update local DB to match cloud
          SqliteService.instance.setSystemSetting(
            'isAutomatic',
            newMode.toString(),
          );
          notifyListeners();
        }
      }
    });
  }

  // Toggle System Mode
  Future<void> toggleSystemMode(bool value) async {
    _isAutomatic = value;
    notifyListeners(); // Optimistic update

    try {
      // Update Firebase
      await FirebaseService().setSystemMode(value);
      // Update Local DB
      await SqliteService.instance.setSystemSetting(
        'isAutomatic',
        value.toString(),
      );
    } catch (e) {
      print('Error toggling system mode: $e');
      // Revert on failure (optional, but good practice)
      // For now, we'll let the listener handle correction if it comes back different
    }
  }

  // Check initial connectivity
  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _isOnline = false;
    }
    notifyListeners();
  }

  // Listen to Firebase connection state (more reliable for app connectivity)
  void _listenToFirebaseConnection() {
    try {
      _firebaseConnectionSubscription = FirebaseDatabase.instance
          .ref(".info/connected")
          .onValue
          .listen((event) {
            final connected = event.snapshot.value as bool? ?? false;
            if (_isOnline != connected) {
              _isOnline = connected;
              notifyListeners();
            }
          });
    } catch (e) {
      print('Error listening to Firebase connection: $e');
      // Fallback to periodic check
      _checkInitialConnectivity();
    }
  }

  // Periodic connectivity check as backup
  void _startPeriodicConnectivityCheck() {
    _connectivityCheckTimer = Timer.periodic(const Duration(seconds: 10), (
      _,
    ) async {
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 3));
        final isConnected =
            result.isNotEmpty && result[0].rawAddress.isNotEmpty;

        if (_isOnline != isConnected) {
          _isOnline = isConnected;
          notifyListeners();
        }
      } catch (e) {
        if (_isOnline) {
          _isOnline = false;
          notifyListeners();
        }
      }
    });
  }

  // Get sensor data for dashboard display
  Map<String, dynamic>? getSensorDataForTile(String sensorType) {
    if (sensorStateMgmt == null || settingsStateMgmt == null) {
      return null;
    }

    final sensors = sensorStateMgmt!.sensors;
    final thresholds = settingsStateMgmt!.thresholds;

    if (sensors.isEmpty || thresholds.isEmpty) {
      return null;
    }

    // Find the sensor
    Sensor? sensor;
    try {
      sensor = sensors.firstWhere(
        (s) =>
            _normalizeSensorType(s.sensorType) ==
            _normalizeSensorType(sensorType),
        orElse: () => sensors.firstWhere(
          (s) => s.sensorType.toLowerCase().contains(sensorType.toLowerCase()),
          orElse: () => sensors.first,
        ),
      );
    } catch (e) {
      print('Sensor not found: $sensorType');
      return null;
    }

    // Apply calibration
    final calibratedValue = sensorStateMgmt!.getCalibratedValue(
      sensor.sensorType,
      sensor.value,
    );

    // Get status directly from sensor
    String status = sensor.status;
    if (status.toUpperCase() == 'OK') {
      status = 'Normal';
    }

    // Get symbol for sensor type
    String symbol = _getSymbolForSensor(sensor.sensorType);

    return {'value': calibratedValue, 'symbol': symbol, 'status': status};
  }

  // Helper to normalize sensor type names
  String _normalizeSensorType(String type) {
    return type.toLowerCase().replaceAll(' ', '');
  }

  // Get symbol for sensor type
  String _getSymbolForSensor(String sensorType) {
    final normalized = _normalizeSensorType(sensorType);
    switch (normalized) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'waterlevel':
      case 'water':
        return '%';
      case 'lightintensity':
      case 'light':
        return 'Lux';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _firebaseConnectionSubscription?.cancel();
    _systemModeSubscription?.cancel();
    _connectivityCheckTimer?.cancel();
    super.dispose();
  }
}
