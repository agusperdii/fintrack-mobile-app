import 'package:savaio/models/profile_model.dart';
import 'package:savaio/repositories/data_sources/remote/auth_remote_data_source.dart';

class ProfileRepository {
  final AuthRemoteDataSource _remoteDataSource;
  UserProfile? _cachedProfile;

  ProfileRepository(this._remoteDataSource);

  Future<UserProfile> getUserProfile() async {
    try {
      final data = await _remoteDataSource.getUserProfile();
      _cachedProfile = data;
      return data;
    } catch (e) {
      if (_cachedProfile != null) return _cachedProfile!;
      rethrow;
    }
  }

  Future<bool> updateProfile({required String fullName, String? username}) {
    return _remoteDataSource.updateProfile(fullName: fullName, username: username);
  }

  Future<bool> updatePassword({required String currentPassword, required String newPassword}) {
    return _remoteDataSource.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  Future<void> syncUser() async {
    await _remoteDataSource.syncUser();
  }
}
