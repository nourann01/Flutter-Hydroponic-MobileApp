import 'package:flutter_test/flutter_test.dart';
import 'package:smart_hydroponic_ui/core/constants/app_imports.dart';

void main() {
  group('User model', () {
    final user = User(
      id: 'uid123',
      email: 'test@example.com',
      name: 'Lina',
      phoneNumber: '0123456789',
    );

    test('toJson returns correct map', () {
      final json = user.toJson();
      expect(json['id'], 'uid123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Lina');
      expect(json['phoneNumber'], '0123456789');
      expect(json['isPushedNotificationEnabled'], false);
      expect(json['isEmailNotificationEnabled'], false);
      expect(json['isSmsNotificationEnabled'], false);
    });

    test('fromJson creates correct User object', () {
      final json = {
        'id': 'uid123',
        'email': 'test@example.com',
        'name': 'Lina',
        'phoneNumber': '0123456789',
        'isPushedNotificationEnabled': true,
        'isEmailNotificationEnabled': true,
        'isSmsNotificationEnabled': true,
      };

      final userFromJson = User.fromJson(json);
      expect(userFromJson.id, 'uid123');
      expect(userFromJson.email, 'test@example.com');
      expect(userFromJson.name, 'Lina');
      expect(userFromJson.phoneNumber, '0123456789');
      expect(userFromJson.isPushedNotificationEnabled, true);
      expect(userFromJson.isEmailNotificationEnabled, true);
      expect(userFromJson.isSmsNotificationEnabled, true);
    });

    test('toJsonString and fromJsonString work correctly', () {
      final jsonString = user.toJsonString();
      final decodedUser = User.fromJsonString(jsonString);

      expect(decodedUser.id, user.id);
      expect(decodedUser.email, user.email);
      expect(decodedUser.name, user.name);
      expect(decodedUser.phoneNumber, user.phoneNumber);
      expect(
        decodedUser.isPushedNotificationEnabled,
        user.isPushedNotificationEnabled,
      );
      expect(
        decodedUser.isEmailNotificationEnabled,
        user.isEmailNotificationEnabled,
      );
      expect(
        decodedUser.isSmsNotificationEnabled,
        user.isSmsNotificationEnabled,
      );
    });

    test('fromJson handles missing notification fields gracefully', () {
      final json = {
        'id': 'uid123',
        'email': 'test@example.com',
        'name': 'Lina',
        'phoneNumber': '0123456789',
      };
      final userFromJson = User.fromJson(json);

      expect(userFromJson.isPushedNotificationEnabled, false);
      expect(userFromJson.isEmailNotificationEnabled, false);
      expect(userFromJson.isSmsNotificationEnabled, false);
    });
  });
}
