import 'dart:async';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

class ControlPanelStateMgmt extends ChangeNotifier {
  final ControlPanelRepository repository;

  ControlPanelStateMgmt({required this.repository});

  // Subscriptions to listen for real-time updates b3d m3ml schedulingg
  StreamSubscription? _waterPumpSub;
  StreamSubscription? _lightsSub;
  StreamSubscription? _nutrientPumpSub;

  void init() {
    _subscribeToActuator('waterPump', (data) {
      if (data != null) {
        waterPump = Actuator.fromFirebase(data);
        notifyListeners();
      }
    });

    _subscribeToActuator('lights', (data) {
      if (data != null) {
        lights = Actuator.fromFirebase(data);
        notifyListeners();
      }
    });

    _subscribeToActuator('nutrientPump', (data) {
      if (data != null) {
        nutrientPump = Actuator.fromFirebase(data);
        notifyListeners();
      }
    });
  }

  void _subscribeToActuator(
    String type,
    Function(Map<dynamic, dynamic>?) onData,
  ) {
    // Cancel existing if any
    if (type == 'waterPump') _waterPumpSub?.cancel();
    if (type == 'lights') _lightsSub?.cancel();
    if (type == 'nutrientPump') _nutrientPumpSub?.cancel();

    // Use repository to get the stream (Data Layer abstraction)
    final stream = repository.listenToActuator(type);
    final sub = stream.listen((event) {
      if (event.snapshot.value != null) {
        onData(event.snapshot.value as Map<dynamic, dynamic>);
      }
    });

    if (type == 'waterPump') _waterPumpSub = sub;
    if (type == 'lights') _lightsSub = sub;
    if (type == 'nutrientPump') _nutrientPumpSub = sub;
  }

  void disposeListeners() {
    _waterPumpSub?.cancel();
    _lightsSub?.cancel();
    _nutrientPumpSub?.cancel();
  }

  Actuator waterPump = Actuator(
    actuatorType: "waterPump",
    intensity: 0.75,
    isOn: true,
    timestamp: DateTime.now().toString(),
  );

  Actuator lights = Actuator(
    actuatorType: "lights",
    intensity: 1.0,
    isOn: true,
    timestamp: DateTime.now().toString(),
  );

  Actuator nutrientPump = Actuator(
    actuatorType: "nutrientPump",
    intensity: 1.0,
    isOn: true,
    timestamp: DateTime.now().toString(),
  );

  // WATER PUMP methods
  Future<void> toggleWaterPump() async {
    waterPump.isOn = !waterPump.isOn;
    waterPump.timestamp = DateTime.now().toIso8601String();
    notifyListeners();
    await repository.sendActuatorCommand(waterPump);
  }

  Future<void> setWaterPumpIntensity(double value) async {
    waterPump.intensity = value;
    waterPump.timestamp = DateTime.now().toIso8601String();
    notifyListeners();
    await repository.sendActuatorCommand(waterPump);
  }

  // LIGHTS methods
  Future<void> toggleLights() async {
    lights.isOn = !lights.isOn;
    lights.timestamp = DateTime.now().toIso8601String();
    notifyListeners();
    await repository.sendActuatorCommand(lights);
  }

  Future<void> setLightsIntensity(double value) async {
    lights.intensity = value;
    lights.timestamp = DateTime.now().toIso8601String();
    notifyListeners();
    await repository.sendActuatorCommand(lights);
  }

  // NUTRIENT PUMP methods
  Future<void> toggleNutrientPump() async {
    nutrientPump.isOn = !nutrientPump.isOn;
    nutrientPump.timestamp = DateTime.now().toIso8601String();
    notifyListeners();
    await repository.sendActuatorCommand(nutrientPump);
  }

  Future<void> setNutrientPumpIntensity(double value) async {
    nutrientPump.intensity = value;
    nutrientPump.timestamp = DateTime.now().toIso8601String();
    notifyListeners();
    await repository.sendActuatorCommand(nutrientPump);
  }

  // Emergency Stop
  Future<void> emergencyStop() async {
    waterPump.isOn = false;
    lights.isOn = false;
    nutrientPump.isOn = false;

    waterPump.timestamp = DateTime.now().toIso8601String();
    lights.timestamp = DateTime.now().toIso8601String();
    nutrientPump.timestamp = DateTime.now().toIso8601String();

    notifyListeners();
    await repository.emergencyStop([waterPump, lights, nutrientPump]);
  }

  //scheduling
  String selectedTaskType = "";
  TimeOfDay? selectedTime;
  double scheduledIntensity = 1.0;
  bool scheduledIsOn = true;

  void setTaskType(String value) {
    selectedTaskType = value;
  }

  void setScheduledIntensity(double value) {
    scheduledIntensity = value;
    notifyListeners();
  }

  void setScheduledIsOn(bool value) {
    scheduledIsOn = value;
    notifyListeners();
  }

  void setScheduledTime(TimeOfDay t) {
    selectedTime = t;
  }

  Future<void> saveScheduledTask() async {
    if (selectedTime == null || selectedTaskType.isEmpty) return;

    final formattedTime =
        "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    final task = ScheduledTask(
      taskType: selectedTaskType,
      scheduledTime: formattedTime,
      status: "pending",
      intensity: scheduledIntensity,
      isOn: scheduledIsOn,
    );

    await repository.addScheduledTask(task);

    notifyListeners();
  }

  void resetScheduleInputs() {
    selectedTaskType = "";
    scheduledIntensity = 1.0;
    scheduledIsOn = true;
    selectedTime = null;
    notifyListeners();
  }

  // Fetch actuator history for UI display
  Future<List<Actuator>> getActuatorHistory(String actuatorType) async {
    return await repository.getActuatorHistory(actuatorType);
  }
}
