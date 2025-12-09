class ScheduledTask {
  int? id;
  String taskType;
  String parameters; 
  String scheduledTime;
  String status;
  double? intensity;
  bool? isOn;

  ScheduledTask({
    this.id,
    required this.taskType,
    this.parameters = "",
    required this.scheduledTime,
    required this.status,
    this.intensity,
    this.isOn,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'taskType': taskType,
      'parameters': parameters,
      'scheduledTime': scheduledTime,
      'status': status,
      'intensity': intensity,
      'isOn': isOn == true ? 1 : 0,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ScheduledTask.fromMap(Map<String, dynamic> map) {
    return ScheduledTask(
      id: map['id'],
      taskType: map['taskType'],
      parameters: map['parameters'] ?? "",
      scheduledTime: map['scheduledTime'],
      status: map['status'],
      intensity: map['intensity'],
      isOn: map['isOn'] == 1,
    );
  }
}
