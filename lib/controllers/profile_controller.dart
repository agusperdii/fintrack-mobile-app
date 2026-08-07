// profile_controller.dart
// Controller yang mengelola state dan logika bisnis untuk profil pengguna,
// termasuk pengambilan data profil, pembaruan profil, dan penggantian password.
import 'package:flutter/material.dart';
import 'package:savaio/models/profile_model.dart';
import 'package:savaio/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileController(this._repository);

  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isUpdatingProfile = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _repository.getMe().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Silakan coba lagi atau logout.');
        },
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? currency,
    String? timezone,
    String? locale,
  }) async {
    _isUpdatingProfile = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        currency: currency,
        timezone: timezone,
        locale: locale,
      );
      _userProfile = updated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword({required String currentPassword, required String newPassword}) async {
    try {
      return await _repository.changePassword(currentPassword: currentPassword, newPassword: newPassword);
    } catch (e) {
      debugPrint('Error updating password: $e');
      return false;
    }
  }
}
