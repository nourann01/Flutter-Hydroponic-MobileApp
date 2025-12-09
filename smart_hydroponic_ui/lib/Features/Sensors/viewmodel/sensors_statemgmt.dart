import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SensorStateMgmt extends ChangeNotifier {
  final SensorRepository repository;

  SensorStateMgmt({required this.repository}) {
    _listenToSensors();
    _loadCalibrations();
  }

  List<Sensor> sensors = [];
  Map<String, List<Sensor>> history = {};
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription? _sensorSubscription;

  void _listenToSensors() {
    print("SensorStateMgmt: Starting sensor stream...");
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _sensorSubscription = repository.listenToAllSensors().listen(
      (updatedSensors) {
        sensors = updatedSensors;
        isLoading = false;
        errorMessage = null; // Clear any previous error
        print("SensorStateMgmt: Sensors updated → $sensors");

        // Refresh history for all updated sensors
        for (var sensor in sensors) {
          _fetchHistoryForSensor(sensor.sensorType);
        }

        notifyListeners();
      },
      onError: (error) {
        print("SensorStateMgmt: Stream error → $error");
        isLoading = false;
        errorMessage = "Failed to load sensor data: $error";
        notifyListeners();
      },
    );
  }

  Future<void> _fetchHistoryForSensor(String sensorType) async {
    final sensorHistory = await repository.getSensorHistory(sensorType);
    history[sensorType] = sensorHistory;
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  //calibration
  Map<String, SensorCalibration> _calibrations = {};

  Future<void> _loadCalibrations() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith('calibration_')) {
        final sensorType = key.replaceFirst('calibration_', '');
        final offset = prefs.getDouble(key) ?? 0.0;
        _calibrations[sensorType] = SensorCalibration(
          sensorType: sensorType,
          offset: offset,
        );
      }
    }
    notifyListeners();
  }

  // Set/update calibration for a sensor
  Future<void> setCalibration(SensorCalibration calibration) async {
    _calibrations[calibration.sensorType] = calibration;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      'calibration_${calibration.sensorType}',
      calibration.offset,
    );
  }

  //get calibration for a sensor
  double getCalibration(String sensorType) {
    return _calibrations[sensorType]?.offset ?? 0.0;
  }

  // Get calibration for a sensor
  double getCalibratedValue(String sensorType, double rawValue) {
    final offset = getCalibration(sensorType);
    return rawValue + offset; // simple offset adjustment
  }

  // Update sensor reading with calibration
  void updateSensorReading(String sensorType, double rawValue) {
    final calibrated = getCalibratedValue(sensorType, rawValue);

    final index = sensors.indexWhere((s) => s.sensorType == sensorType);

    if (index != -1) {
      sensors[index] = sensors[index].copyWith(value: calibrated);

      notifyListeners();
    }
  }
}
