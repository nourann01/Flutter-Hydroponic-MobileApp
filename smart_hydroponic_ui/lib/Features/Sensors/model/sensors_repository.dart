import 'package:smart_hydroponic_ui/Features/Sensors/model/sensor_model.dart';
import 'package:smart_hydroponic_ui/core/services/firebase_service.dart';
import 'package:smart_hydroponic_ui/core/services/sqlite_service.dart';

class SensorRepository {
  final FirebaseService firebaseService;
  final SqliteService sqliteService;

  SensorRepository({
    required this.firebaseService,
    required this.sqliteService,
  });

  // Fetch the last reading of a specific sensor type from Firebase, might not be needed
  Future<Sensor?> fetchLastSensorReading(String sensorType) async {
    try {
      final snapshot = await firebaseService.readSensorData(sensorType);
      final data = snapshot.value;
      if (data == null) return null;

      final sensorMap = Map<String, dynamic>.from(data as Map);
      return Sensor.fromMap(sensorMap);
    } catch (e) {
      print('Error fetching $sensorType from Firebase: $e');
      return null;
    }
  }

  // Cache to prevent duplicate logging
  final Map<String, Sensor> _lastKnownSensors = {};

  // Listen to ALL sensors in real-time
  Stream<List<Sensor>> listenToAllSensors() {
    print("Listening to all sensors in Firebase...");

    return firebaseService.listenToFirebaseNode("sensors").map((event) {
      final data = event.snapshot.value;

      if (data == null) {
        print("Firebase returned NULL for /sensors");
        return <Sensor>[];
      }

      List<Sensor> list = [];

      try {
        if (data is Map) {
          final sensorsMap = Map<String, dynamic>.from(data);
          sensorsMap.forEach((key, value) {
            try {
              if (value is Map) {
                final sensorMap = Map<String, dynamic>.from(value);
                // If the key is the sensor type, we might want to inject it if missing
                if (!sensorMap.containsKey('sensorType')) {
                  sensorMap['sensorType'] = key;
                }
                final sensor = Sensor.fromMap(sensorMap);
                list.add(sensor);

                // Log to SQLite only if changed
                _logIfChanged(sensor);
              }
            } catch (e) {
              print("Error parsing sensor at key $key: $e. Data: $value");
            }
          });
        } else if (data is List) {
          for (var i = 0; i < data.length; i++) {
            final item = data[i];
            if (item != null && item is Map) {
              try {
                final sensorMap = Map<String, dynamic>.from(item);
                final sensor = Sensor.fromMap(sensorMap);
                list.add(sensor);
                _logIfChanged(sensor);
              } catch (e) {
                print("Error parsing sensor at index $i: $e");
              }
            }
          }
        } else {
          print("Unknown data structure for sensors: ${data.runtimeType}");
        }
      } catch (e) {
        print("CRITICAL ERROR parsing sensors data: $e");
        return <Sensor>[];
      }

      print("Parsed sensors count: ${list.length}");
      return list;
    });
  }

  void _logIfChanged(Sensor sensor) {
    final lastSensor = _lastKnownSensors[sensor.sensorType];
    bool hasChanged = false;

    if (lastSensor == null) {
      hasChanged = true;
    } else {
      // Compare fields
      if (lastSensor.timestamp != sensor.timestamp ||
          lastSensor.value != sensor.value ||
          lastSensor.status != sensor.status) {
        hasChanged = true;
      }
    }

    if (hasChanged) {
      _logSensorData(sensor);
      _lastKnownSensors[sensor.sensorType] = sensor;
    }
  }

  Future<void> _logSensorData(Sensor sensor) async {
    try {
      await sqliteService.insertSensorData(sensor.toMap());
      print("Logged ${sensor.sensorType} to SQLite");
    } catch (e) {
      print("Error logging sensor to SQLite: $e");
    }
  }

  Future<List<Sensor>> getSensorHistory(String sensorType) async {
    try {
      final data = await sqliteService.getSensorData(sensorType);
      return data.map((e) => Sensor.fromMap(e)).toList();
    } catch (e) {
      print("Error fetching history for $sensorType: $e");
      return [];
    }
  }
}
