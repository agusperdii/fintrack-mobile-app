import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/profile_model.dart';

class AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSource(this._client);

  /// POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      '${ApiConfig.baseUrl}/auth/login',
      body: {'email': email, 'password': password},
    ) as Map<String, dynamic>;
    return data;
  }

  /// POST /auth/register
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      '${ApiConfig.baseUrl}/auth/register',
      body: {'full_name': fullName, 'email': email, 'password': password},
    ) as Map<String, dynamic>;
 return data;
  }

  /// POST /auth/refresh
  Future<Map<String, dynamic>> refresh({required String refreshToken}) async {
    final data = await _client.post(
      '${ApiConfig.baseUrl}/auth/refresh',
      body: {'refresh_token': refreshToken},
    ) as Map<String, dynamic>;
    return data;
  }

  /// POST /auth/logout
  Future<void> logout() async {
    await _client.post('${ApiConfig.baseUrl}/auth/logout', body: {});
  }

  /// GET /auth/me
  Future<UserProfile> getMe() async {
    final data = await _client.get('${ApiConfig.baseUrl}/auth/me') as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  /// PATCH /auth/password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.patch(
      '${ApiConfig.baseUrl}/auth/password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  /// GET /users/me
  Future<UserProfile> getProfile() async {
    final data = await _client.get('${ApiConfig.baseUrl}/users/me') as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  /// PATCH /users/me
  Future<UserProfile> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? currency,
    String? timezone,
    String? locale,
  }) async {
    final body = <String, dynamic>{};
    if (fullName  != null) body['full_name']  = fullName;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    if (currency  != null) body['currency']   = currency;
    if (timezone  != null) body['timezone']   = timezone;
    if (locale    != null) body['locale']     = locale;
    final data = await _client.patch(
      '${ApiConfig.baseUrl}/users/me',
      body: body,
    ) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }
}
