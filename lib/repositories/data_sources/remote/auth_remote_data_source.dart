import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/core/constants/api_config.dart';
import 'package:savaio/models/profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserProfile> getUserProfile();
  Future<bool> updateProfile({required String fullName, String? username});
  Future<bool> updatePassword({required String currentPassword, required String newPassword});
  Future<Map<String, String>> syncUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final String baseUrl = ApiConfig.baseUrl;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfile> getUserProfile() async {
    final response = await apiClient.get('$baseUrl/auth/me');
    return UserProfile.fromJson(response);
  }

  @override
  Future<bool> updateProfile({required String fullName, String? username}) async {
    await apiClient.patch('$baseUrl/auth/me', body: {
      'full_name': fullName,
      'username': username,
    });
    return true;
  }

  @override
  Future<bool> updatePassword({required String currentPassword, required String newPassword}) async {
    await apiClient.post('$baseUrl/auth/me/change-password', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
    return true;
  }

  @override
  Future<Map<String, String>> syncUser() async {
    final response = await apiClient.get('$baseUrl/auth/me');
    return {
      'id': response['id'].toString(),
      'email': response['email'] ?? '',
      'full_name': response['full_name'] ?? '',
    };
  }
}
