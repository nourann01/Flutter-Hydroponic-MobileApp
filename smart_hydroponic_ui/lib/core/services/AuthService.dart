import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import 'sqlite_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_hydroponic_ui/Features/login_register/model/User.dart';

class AuthService {
  final fb.FirebaseAuth firebaseAuth = fb.FirebaseAuth.instance;

  // -----------------------
  // Firebase Auth Methods
  // -----------------------
  Future<fb.User?> registerFirebase({
    required String email,
    required String password,
  }) async {
    try {
      fb.UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Firebase registration failed: $e');
      rethrow;
    }
  }

  Future<fb.User?> loginFirebase({
    required String email,
    required String password,
  }) async {
    try {
      fb.UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Firebase login failed: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
    } catch (e) {
      print('Firebase password reset failed: $e');
      rethrow;
    }
  }

  Future<void> logoutFirebase() async {
    try {
      await firebaseAuth.signOut();
      print('User logged out from Firebase');
    } catch (e) {
      print('Firebase logout failed: $e');
      rethrow;
    }
  }

  // -----------------------
  // SQLite Methods
  // -----------------------
  Future<void> saveUserSQLite(User user) async {
    final db = await SqliteService.instance.database;
    await db.insert('users', {
      'uid': user.id,
      'fullName': user.name,
      'phoneNumber': user.phoneNumber,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserSQLite(String uid, String email) async {
    final db = await SqliteService.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (result.isEmpty) return null;

    final data = result.first;

    // Load notifications from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    bool push = prefs.getBool('${uid}_push') ?? false;
    bool emailNotif = prefs.getBool('${uid}_email') ?? false;
    bool sms = prefs.getBool('${uid}_sms') ?? false;

    return User(
      id: uid,
      email: email,
      name: data['fullName'],
      phoneNumber: data['phoneNumber'],
      isPushedNotificationEnabled: push,
      isEmailNotificationEnabled: emailNotif,
      isSmsNotificationEnabled: sms,
    );
  }

  Future<void> updateUserSQLite(User user) async {
    final db = await SqliteService.instance.database;
    await db.update(
      'users',
      {'fullName': user.name, 'phoneNumber': user.phoneNumber},
      where: 'uid = ?',
      whereArgs: [user.id],
    );
  }

  // -----------------------
  // SharedPreferences Methods (Notifications)
  // -----------------------
  Future<void> saveNotifications(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${user.id}_push', user.isPushedNotificationEnabled);
    await prefs.setBool('${user.id}_email', user.isEmailNotificationEnabled);
    await prefs.setBool('${user.id}_sms', user.isSmsNotificationEnabled);
  }

  Future<void> loadNotifications(User user) async {
    final prefs = await SharedPreferences.getInstance();
    user.isPushedNotificationEnabled =
        prefs.getBool('${user.id}_push') ?? false;
    user.isEmailNotificationEnabled =
        prefs.getBool('${user.id}_email') ?? false;
    user.isSmsNotificationEnabled = prefs.getBool('${user.id}_sms') ?? false;
  }

  // -----------------------
  // SharedPreferences Methods (Current user)
  // -----------------------
  Future<void> saveToSharedPreferences(String email, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_email', email);
    await prefs.setString('current_uid', uid);
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_email');
  }

  Future<String?> getSavedUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_uid');
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_email');
    await prefs.remove('current_uid');
  }

  // -----------------------
  // Firebase: Get current user
  // -----------------------
  fb.User? getCurrentFirebaseUser() {
    return firebaseAuth.currentUser;
  }
}
