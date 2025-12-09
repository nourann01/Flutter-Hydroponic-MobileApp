import 'dart:convert';

class User {
  final String id; // Firebase UID
  final String email; // for login and display
  String name;
  String phoneNumber;

  // Notification settings
  bool isPushedNotificationEnabled;
  bool isEmailNotificationEnabled;
  bool isSmsNotificationEnabled;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    this.isPushedNotificationEnabled = false,
    this.isEmailNotificationEnabled = false,
    this.isSmsNotificationEnabled = false,
  });

  // Convert User object to JSON (for SQLite or SharedPreferences)
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phoneNumber': phoneNumber,
    'isPushedNotificationEnabled': isPushedNotificationEnabled,
    'isEmailNotificationEnabled': isEmailNotificationEnabled,
    'isSmsNotificationEnabled': isSmsNotificationEnabled,
  };

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    isPushedNotificationEnabled: json['isPushedNotificationEnabled'] ?? false,
    isEmailNotificationEnabled: json['isEmailNotificationEnabled'] ?? false,
    isSmsNotificationEnabled: json['isSmsNotificationEnabled'] ?? false,
  );

  // Convert to JSON string for SharedPreferences
  String toJsonString() => jsonEncode(toJson());

  // Decode JSON string into User object
  factory User.fromJsonString(String jsonString) =>
      User.fromJson(jsonDecode(jsonString));
}
