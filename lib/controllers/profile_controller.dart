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
      _userProfile = await _repository.getUserProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({required String fullName, String? username}) async {
    _isUpdatingProfile = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateProfile(fullName: fullName, username: username);
      if (success) {
        await fetchProfile();
        return true;
      }
      return false;
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
      return await _repository.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
    } catch (e) {
      debugPrint('Error updating password: $e');
      return false;
    }
  }
}
