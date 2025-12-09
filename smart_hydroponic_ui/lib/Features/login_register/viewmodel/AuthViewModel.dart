import 'package:flutter/material.dart';
import '../model/User.dart';
import 'package:smart_hydroponic_ui/core/services/AuthService.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService = AuthService();

  Map<String, User> allUsers = {};
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  /// -------------------------
  /// Login state
  /// -------------------------
  bool get isLoggedIn => currentUser != null;

  /// -------------------------
  /// Initialize user from SharedPreferences + Firebase + SQLite
  /// -------------------------
  Future<void> initializeUser() async {
    try {
      isLoading = true;
      notifyListeners();

      final savedEmail = await authService.getSavedEmail();
      final savedUid = await authService.getSavedUid();

      if (savedEmail != null && savedUid != null) {
        final fbUser = authService.getCurrentFirebaseUser();
        if (fbUser != null && fbUser.uid == savedUid) {
          // Load user from SQLite
          User? user = await authService.getUserSQLite(fbUser.uid, savedEmail);

          // If not exists locally, create default
          if (user == null) {
            user = User(
              id: fbUser.uid,
              email: savedEmail,
              name: "",
              phoneNumber: "",
            );
            await authService.saveUserSQLite(user);
            await authService.saveNotifications(user);
          }

          currentUser = user;
          allUsers[savedEmail] = user;
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// -------------------------
  /// Register a new user (Firebase + SQLite)
  /// -------------------------
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // 1️⃣ Firebase registration
      final fbUser = await authService.registerFirebase(
        email: email,
        password: password,
      );
      if (fbUser == null) throw "Firebase registration failed";

      // 2️⃣ Save locally
      final user = User(
        id: fbUser.uid,
        email: email,
        name: fullName,
        phoneNumber: phone,
      );
      await authService.saveUserSQLite(user);
      await authService.saveNotifications(user);
      await authService.saveToSharedPreferences(email, fbUser.uid);

      currentUser = user;
      allUsers[email] = user;

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// -------------------------
  /// Login user (Firebase-only, create SQLite record if missing)
  /// -------------------------
  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading = true;
      notifyListeners();

      // Firebase login
      final fbUser = await authService.loginFirebase(
        email: email,
        password: password,
      );
      if (fbUser == null) throw "Firebase login failed";

      // Load user from SQLite
      User? user = await authService.getUserSQLite(fbUser.uid, email);

      // If not exists locally, create record
      if (user == null) {
        user = User(id: fbUser.uid, email: email, name: "", phoneNumber: "");
        await authService.saveUserSQLite(user);
        await authService.saveNotifications(user);
      }

      currentUser = user;
      allUsers[email] = user;
      await authService.saveToSharedPreferences(email, fbUser.uid);

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// -------------------------
  /// Logout
  /// -------------------------
  Future<void> logout() async {
    if (currentUser == null) return;

    try {
      await authService.logoutFirebase();
      await authService.clearSharedPreferences();
      currentUser = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// -------------------------
  /// Update user fields locally + notifications
  /// -------------------------
  Future<void> updateUser({
    String? name,
    String? phoneNumber,
    bool? isPushedNotificationEnabled,
    bool? isEmailNotificationEnabled,
    bool? isSmsNotificationEnabled,
  }) async {
    if (currentUser == null) return;

    if (name != null) currentUser!.name = name;
    if (phoneNumber != null) currentUser!.phoneNumber = phoneNumber;
    if (isPushedNotificationEnabled != null)
      currentUser!.isPushedNotificationEnabled = isPushedNotificationEnabled;
    if (isEmailNotificationEnabled != null)
      currentUser!.isEmailNotificationEnabled = isEmailNotificationEnabled;
    if (isSmsNotificationEnabled != null)
      currentUser!.isSmsNotificationEnabled = isSmsNotificationEnabled;

    // Update SQLite + notifications
    await authService.updateUserSQLite(currentUser!);
    await authService.saveNotifications(currentUser!);

    allUsers[currentUser!.email] = currentUser!;
    notifyListeners();
  }

  /// -------------------------
  /// Reset password via Firebase
  /// -------------------------
  Future<void> resetPassword(String email) async {
    try {
      await authService.sendPasswordResetEmail(email);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
