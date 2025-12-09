class SensorThreshold {
  String sensorType;
  double minValue;
  double maxValue;

  SensorThreshold({
    required this.sensorType,
    required this.minValue,
    required this.maxValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'sensorType': sensorType,
      'minValue': minValue,
      'maxValue': maxValue,
    };
  }

  factory SensorThreshold.fromMap(Map<String, dynamic> map) {
    return SensorThreshold(
      sensorType: map['sensorType'],
      minValue: map['minValue'].toDouble(),
      maxValue: map['maxValue'].toDouble(),
    );
  }
}
