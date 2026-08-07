// profile_repository.dart
// Repository untuk mengelola data profil pengguna: ambil profil (dengan
// cache), perbarui profil, dan ubah kata sandi.

import 'package:savaio/models/profile_model.dart';
import 'package:savaio/repositories/data_sources/remote/auth_remote_data_source.dart';

class ProfileRepository {
  final AuthRemoteDataSource _remoteDataSource;
  UserProfile? _cachedProfile;

  ProfileRepository(this._remoteDataSource);

  Future<UserProfile> getMe() async {
    try {
      final data = await _remoteDataSource.getMe();
      _cachedProfile = data;
      return data;
    } catch (e) {
      if (_cachedProfile != null) return _cachedProfile!;
      rethrow;
    }
  }

  Future<UserProfile> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? currency,
    String? timezone,
    String? locale,
  }) async {
    final updated = await _remoteDataSource.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
      currency: currency,
      timezone: timezone,
      locale: locale,
    );
    _cachedProfile = updated;
    return updated;
  }

  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
