class Actuator {
  int? id;
  String actuatorType;
  double intensity;
  bool isOn;
  String timestamp;

  Actuator({
    this.id,
    required this.actuatorType,
    required this.intensity,
    required this.isOn,
    required this.timestamp,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actuatorType': actuatorType,
      'status': isOn ? 1 : 0,
      'intensity': intensity,
      'timestamp': timestamp,
    };
  }

  // Convert SQLite row back to Actuator object
  factory Actuator.fromMap(Map<String, dynamic> map) {
    return Actuator(
      id: map['id'],
      actuatorType: map['actuatorType'] ?? 'unknown',
      intensity: map['intensity'],
      isOn: map['status'] == 1,
      timestamp: map['timestamp'] ?? DateTime.now().toString(),
    );
  }

  // Convert Firebase JSON back to Actuator object
  factory Actuator.fromFirebase(Map<dynamic, dynamic> map) {
    return Actuator(
      id: null, 
      actuatorType: map['actuatorType'] ?? 'unknown',
      intensity: (map['intensity'] as num?)?.toDouble() ?? 0.0,
      isOn: map['isOn'] as bool? ?? false,
      timestamp: map['timestamp'] ?? DateTime.now().toString(),
    );
  }
}
