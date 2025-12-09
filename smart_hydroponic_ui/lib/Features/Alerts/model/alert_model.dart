class Alert {
  final int? id;
  final String sensorType;
  final String previousStatus;
  final String currentStatus;
  final double sensorValue;
  final String message;
  final String timestamp;
  final bool isRead;

  Alert({
    this.id,
    required this.sensorType,
    required this.previousStatus,
    required this.currentStatus,
    required this.sensorValue,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  // Determine severity based on current status
  String get severity {
    switch (currentStatus.toLowerCase()) {
      case 'danger':
        return 'danger';
      case 'warning':
        return 'warning';
      case 'normal':
      case 'ok':
        return 'info';
      default:
        return 'unknown';
    }
  }

  // Generate alert title
  String get title {
    return '$sensorType Status Changed';
  }

  // Convert Alert object to Map for SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'sensorType': sensorType,
      'previousStatus': previousStatus,
      'currentStatus': currentStatus,
      'sensorValue': sensorValue,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead ? 1 : 0,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Create Alert object from Map (from SQLite)
  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] as int?,
      sensorType: map['sensorType']?.toString() ?? 'Unknown',
      previousStatus: map['previousStatus']?.toString() ?? '',
      currentStatus: map['currentStatus']?.toString() ?? '',
      sensorValue:
          double.tryParse(map['sensorValue']?.toString() ?? '0') ?? 0.0,
      message: map['message']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? '',
      isRead: (map['isRead'] as int?) == 1,
    );
  }

  Alert copyWith({
    int? id,
    String? sensorType,
    String? previousStatus,
    String? currentStatus,
    double? sensorValue,
    String? message,
    String? timestamp,
    bool? isRead,
  }) {
    return Alert(
      id: id ?? this.id,
      sensorType: sensorType ?? this.sensorType,
      previousStatus: previousStatus ?? this.previousStatus,
      currentStatus: currentStatus ?? this.currentStatus,
      sensorValue: sensorValue ?? this.sensorValue,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
