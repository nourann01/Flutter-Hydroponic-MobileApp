class Sensor {
  int? id;
  String sensorType;
  double value;
  String status;
  String timestamp;

  Sensor({
    this.id,
    required this.sensorType,
    required this.value,
    required this.status,
    required this.timestamp,
  });

  // Convert Sensor object to Map for SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'sensorType': sensorType,
      'value': value,
      'status': status,
      'timestamp': timestamp,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Create Sensor object from Map (from SQLite)
  factory Sensor.fromMap(Map<String, dynamic> map) {
    return Sensor(
      id: map['id'],
      sensorType: map['sensorType']?.toString() ?? 'Unknown',
      value: double.tryParse(map['value']?.toString() ?? '0') ?? 0.0,
      status: map['status']?.toString() ?? 'Unknown',
      timestamp: map['timestamp']?.toString() ?? '',
    );
  }

  Sensor copyWith({
    String? sensorType,
    double? value,
    String? status,
    String? timestamp,
  }) {
    return Sensor(
      sensorType: sensorType ?? this.sensorType,
      value: value ?? this.value,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
