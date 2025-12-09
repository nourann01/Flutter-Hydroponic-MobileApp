import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_hydroponic_ui/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  static Future<void> initialize() async {
    // Test generic internet connectivity
    try {
      print('Testing internet connection...');
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('INTERNET CONNECTION: AVAILABLE');
      }
    } catch (e) {
      print('INTERNET CONNECTION: FAILED ($e)');
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseDatabase.instance.setLoggingEnabled(true); // Enable internal logs
      print('Firebase initialized successfully');

      // Monitor connection state
      FirebaseDatabase.instance.ref(".info/connected").onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        print(
          'FIREBASE CONNECTION STATE: ${connected ? "CONNECTED" : "DISCONNECTED"}',
        );
      });
    } catch (e) {
      print('Firebase initialization failed: $e');
      rethrow;
    }
  }

  //actuator methods
  // Write actuator data
  Future<void> writeActuatorData(Map<String, dynamic> data) async {
    final String actuatorType = data['actuatorType'];
    print('Attempting to write to Firebase: actuators/$actuatorType = $data');
    try {
      await _dbRef
          .child('actuators')
          .child(actuatorType)
          .set(data)
          .timeout(const Duration(seconds: 5));
      print('Successfully wrote to Firebase: actuators/$actuatorType');
    } catch (e) {
      print('Failed to write to Firebase: $e');
      rethrow;
    }
  }

  //threshold methods
  // Write thresholds for a sensor
  Future<void> writeThresholdData(Map<String, dynamic> data) async {
    final String sensorType = data['sensorType'];
    print('Attempting to write to Firebase: thresholds/$sensorType = $data');
    try {
      await _dbRef
          .child('thresholds')
          .child(sensorType)
          .set(data)
          .timeout(const Duration(seconds: 5));
      print('Successfully wrote to Firebase: thresholds/$sensorType');
    } catch (e) {
      print('Failed to write to Firebase: $e');
      rethrow;
    }
  }

  //sensor methods
  // get last sensor reading
  Future<DataSnapshot> readSensorData(String sensorKey) async {
    print("[SENSOR READ] Fetching sensors/$sensorKey");
    return await _dbRef.child('sensors').child(sensorKey).get();
  }

  Stream<DatabaseEvent> listenToFirebaseNode(String path) {
    print("FirebaseService: Listening to /$path");
    return _dbRef.child(path).onValue;
  }

  // System Mode
  Future<void> setSystemMode(bool isAutomatic) async {
    print('Setting system mode to: ${isAutomatic ? "Automatic" : "Manual"}');
    try {
      await _dbRef.child('system/isAutomatic').set(isAutomatic);
    } catch (e) {
      print('Failed to set system mode: $e');
      rethrow;
    }
  }

  Stream<DatabaseEvent> listenToSystemMode() {
    return _dbRef.child('system/isAutomatic').onValue;
  }
}
