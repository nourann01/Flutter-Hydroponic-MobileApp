import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class ControlPanelRepository {
  final FirebaseService firebaseService;
  final SqliteService sqliteService;

  ControlPanelRepository({
    required this.firebaseService,
    required this.sqliteService,
  });

  // Actuators

  /// Listen to actuator updates
  Stream<DatabaseEvent> listenToActuator(String actuatorType) {
    return firebaseService.listenToFirebaseNode('actuators/$actuatorType');
  }

  /// Send actuator command to Firebase and log locally
  Future<void> sendActuatorCommand(Actuator actuator) async {
    final data = {
      'actuatorType': actuator.actuatorType,
      'isOn': actuator.isOn,
      'intensity': actuator.intensity,
      'timestamp': actuator.timestamp,
    };

    //  Send to Firebase
    await firebaseService.writeActuatorData(data);

    // Log in SQLite
    await sqliteService.insertActuatorLog(actuator.toMap());
  }

  /// Fetch actuator history from SQLite
  Future<List<Actuator>> getActuatorHistory(String actuatorType) async {
    final logs = await sqliteService.getActuatorLogs(actuatorType);
    return logs.map((map) => Actuator.fromMap(map)).toList();
  }

  /// Emergency stop: turn all actuators off
  Future<void> emergencyStop(List<Actuator> actuators) async {
    for (var actuator in actuators) {
      actuator.isOn = false;
      actuator.timestamp = DateTime.now().toString();
      await sendActuatorCommand(actuator);
    }
  }

  // scheduling

  /// Add a new scheduled task
  Future<void> addScheduledTask(ScheduledTask task) async {
    // Log in SQLite
    await sqliteService.insertScheduledTask(task.toMap());
  }
}
