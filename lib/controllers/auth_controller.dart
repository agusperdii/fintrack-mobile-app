import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:savaio/core/constants/api_config.dart';
import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/core/network/exceptions.dart';

class AuthController extends ChangeNotifier {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey  = 'auth_user';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  String? _token;
  String? _refreshToken;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  String? get token         => _token;
  String?  get refreshToken   => _refreshToken;
  Map<String, dynamic>? get user => _user;
  bool     get isLoading     => _isLoading;
  String?  get error         => _error;
  bool     get isAuthenticated => _token != null;
  String?  get userId        => _user?['id']?.toString();
  String?  get userEmail     => _user?['email']?.toString();
  String?  get userFullName  => _user?['full_name']?.toString();
  String   get currency => _user?['currency']?.toString() ?? 'IDR';
  String   get timezone      => _user?['timezone']?.toString() ?? 'Asia/Jakarta';

  AuthController() { _init(); }

  Future<void> _init() async {
    _token        = await _secure.read(key: _accessKey);
    _refreshToken = await _secure.read(key: _refreshKey);
    final raw = await _secure.read(key: _userKey);
    if (raw != null) {
      try { _user = jsonDecode(raw) as Map<String, dynamic>; } catch (_) {}
    }
    notifyListeners();
  }

  /// POST /auth/register
  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final data = await _unauthClient().post(
        '${ApiConfig.baseUrl}/auth/register',
        body: {'full_name': fullName, 'email': email, 'password': password},
      );
      _applyTokens(data);
      await _saveSession();
      _isLoading = false; notifyListeners();
      return _token != null;
    } on ApiErrorException catch (e) {
      _error = e.message; _isLoading = false; notifyListeners(); return false;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  /// POST /auth/login
  Future<bool> login(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final data = await _unauthClient().post(
        '${ApiConfig.baseUrl}/auth/login',
        body: {'email': email, 'password': password},
      );
      _applyTokens(data);
      await _saveSession();
      _isLoading = false; notifyListeners();
      return _token != null;
    } on ApiErrorException catch (e) {
      _error = e.message; _isLoading = false; notifyListeners(); return false;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  /// POST /auth/logout
  Future<void> logout() async {
    try {
      await ApiClient(authController: this)
          .post('${ApiConfig.baseUrl}/auth/logout', body: {});
    } catch (_) {}
    await _clearSession();
  }

  Future<void> forceLogout() => _clearSession();

  /// POST /auth/refresh — called by ApiClient on 401
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    try {
      final data = await _unauthClient().post(
        '${ApiConfig.baseUrl}/auth/refresh',
        body: {'refresh_token': _refreshToken},
      );
      _applyTokens(data);
      await _saveSession();
      notifyListeners();
      return _token != null;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  void _applyTokens(Map<String, dynamic> data) {
    _token        = data['access_token']?.toString();
    _refreshToken = data['refresh_token']?.toString();
    _user         = data['user']  as Map<String, dynamic>?;
  }

  Future<void> _saveSession() async {
    if (_token        != null) await _secure.write(key: _accessKey,  value: _token);
    if (_refreshToken != null) await _secure.write(key: _refreshKey, value: _refreshToken);
    if (_user        != null) await _secure.write(key: _userKey, value: jsonEncode(_user));
  }

  Future<void> _clearSession() async {
    _token = null; _refreshToken = null; _user = null;
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
    await _secure.delete(key: _userKey);
    notifyListeners();
  }

  ApiClient _unauthClient() => ApiClient(authController: this);

  void clearError() { _error = null; notifyListeners(); }
}
