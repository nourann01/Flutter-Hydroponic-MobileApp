import 'package:smart_hydroponic_ui/Features/Settings/model/thresholds_model.dart';
import 'package:smart_hydroponic_ui/core/services/firebase_service.dart';

class ThresholdRepository {
  final FirebaseService firebaseService;

  ThresholdRepository({required this.firebaseService});

  Future<void> saveThreshold(SensorThreshold threshold) async {
    try {
      await firebaseService.writeThresholdData(threshold.toMap());
      print("Threshold saved via repository for ${threshold.sensorType}");
    } catch (e) {
      print("Failed to save threshold via repository: $e");
      rethrow;
    }
  }

  Stream<List<SensorThreshold>> listenToThresholds() {
    return firebaseService.listenToFirebaseNode("thresholds").map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final mapData = Map<String, dynamic>.from(data as Map);
      return mapData.entries
          .map(
            (e) => SensorThreshold.fromMap(Map<String, dynamic>.from(e.value)),
          )
          .toList();
    });
  }
}
