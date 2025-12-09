import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class SettingsStateMgmt extends ChangeNotifier {
  final ThresholdRepository repository;

  List<SensorThreshold> thresholds = [];

  SettingsStateMgmt({required this.repository}) {
    _loadDefaults();
  }

  void _loadDefaults() {
    thresholds = [
      SensorThreshold(sensorType: "temperature", minValue: 0, maxValue: 100),
      SensorThreshold(sensorType: "humidity", minValue: 0, maxValue: 100),
      SensorThreshold(sensorType: "waterLevel", minValue: 0, maxValue: 100),
      SensorThreshold(sensorType: "lightIntensity", minValue: 0, maxValue: 100),
    ];
  }

  Future<void> updateThreshold(SensorThreshold threshold) async {
    try {
      await repository.saveThreshold(threshold);
      final index = thresholds.indexWhere(
        (t) => t.sensorType == threshold.sensorType,
      );
      if (index != -1) {
        thresholds[index] = threshold;
        notifyListeners();
      }
    } catch (e) {
      print("Error updating threshold: $e");
    }
  }
}
