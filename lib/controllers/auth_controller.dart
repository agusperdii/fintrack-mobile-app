// auth_controller.dart
// Controller yang menangani autentikasi pengguna (login, register, OTP, Google
// Sign-In) serta pengelolaan sesi/token dan sinkronisasi FCM token ke backend.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/core/constants/api_config.dart';
import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/core/network/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class AuthController extends ChangeNotifier {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey  = 'auth_user';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  String? _token;
  String? _refreshToken;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _hasSeenLanding = false;
  String? _error;

  String? get token         => _token;
  String?  get refreshToken   => _refreshToken;
  Map<String, dynamic>? get user => _user;
  bool     get isLoading     => _isLoading;
  bool     get isInitialized => _isInitialized;
  bool     get hasSeenLanding => _hasSeenLanding;
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

    _hasSeenLanding = sl.prefs.getBool('has_seen_landing') ?? false;
    
    _isInitialized = true;
    notifyListeners();

    if (Platform.isAndroid) {
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
        _syncFCMToken(fcmToken);
      });
    }
    
    if (_token != null) {
      _syncFCMToken();
    }

    // Mendengarkan perubahan Supabase Auth untuk keperluan deep linking
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;
      if (session != null && event == AuthChangeEvent.signedIn) {
        if (_token == null) {
          exchangeSupabaseToken(session.accessToken);
        }
      }
    });
  }

  Future<void> setHasSeenLanding(bool value) async {
    _hasSeenLanding = value;
    await sl.prefs.setBool('has_seen_landing', value);
    notifyListeners();
  }

  /// Tukar Token Supabase ke Backend Savaio
  Future<bool> exchangeSupabaseToken(String supabaseToken) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final data = await _unauthClient().post(
        '${ApiConfig.baseUrl}/auth/supabase-login',
        body: {'access_token': supabaseToken},
      );
      _applyTokens(data);
      await _saveSession();
      
      _syncFCMToken();
      
      _isLoading = false; notifyListeners();
      return _token != null;
    } on ApiErrorException catch (e) {
      _error = e.message; _isLoading = false; notifyListeners(); return false;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  /// Supabase Register (dengan email konfirmasi via OTP)
  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      _isLoading = false; notifyListeners();
      // Belum dapat token, arahkan ke halaman verifikasi email
      return true;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  /// Verifikasi Email menggunakan OTP 6 Digit
  Future<bool> verifyEmailOTP(String email, String otp) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        token: otp,
        email: email,
      );
      if (response.session != null) {
        return await exchangeSupabaseToken(response.session!.accessToken);
      }
      _isLoading = false; notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  /// Supabase Login (Email)
  Future<bool> login(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        return await exchangeSupabaseToken(response.session!.accessToken);
      }
      _isLoading = false; notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  bool _isGoogleSignInInitialized = false;

  /// Supabase Login (Google Native)
  Future<bool> loginWithGoogle() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      if (!_isGoogleSignInInitialized) {
        final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
        final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
        await GoogleSignIn.instance.initialize(
          serverClientId: webClientId.isNotEmpty ? webClientId : null,
          clientId: iosClientId.isNotEmpty ? iosClientId : null,
        );
        _isGoogleSignInInitialized = true;
      }
      
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await GoogleSignIn.instance.authenticate();
      } catch (e) {
        _isLoading = false; notifyListeners();
        // Pengguna membatalkan atau terjadi error saat Google Sign In
        return false;
      }

      
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Missing Google Auth Token';
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      
      if (response.session != null) {
         return await exchangeSupabaseToken(response.session!.accessToken);
      }
      
      _isLoading = false; notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString(); _isLoading = false; notifyListeners(); return false;
    }
  }

  /// POST /auth/logout
  Future<void> logout({bool resetLanding = false}) async {
    try {
      await ApiClient(authController: this)
          .post('${ApiConfig.baseUrl}/auth/logout', body: {});
    } catch (_) {}
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    await _clearSession(resetLanding: resetLanding);
  }

  Future<void> forceLogout() async {
    if (!isAuthenticated) return;
    
    debugPrint('[AuthController] Force logout triggered due to invalid session');
    await _clearSession();
  }

  /// POST /auth/refresh — called by ApiClient on 401
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    try {
      final data = await _unauthClient().post(
        '${ApiConfig.baseUrl}/auth/refresh',
        body: {'refresh_token': _refreshToken},
      ).timeout(const Duration(seconds: 5));
      _applyTokens(data);
      await _saveSession();
      notifyListeners();
      return _token != null;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      // Jika refresh gagal, lebih aman menghapus semua sesi agar tidak terjadi loading loop
      await forceLogout();
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

  Future<void> _clearSession({bool resetLanding = false}) async {
    _token = null; _refreshToken = null; _user = null;
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
    await _secure.delete(key: _userKey);
    
    if (resetLanding) {
      _hasSeenLanding = false;
      await sl.prefs.setBool('has_seen_landing', false);
    }
    
    notifyListeners();
  }

  ApiClient _unauthClient() => ApiClient(authController: this);

  Future<void> _syncFCMToken([String? token]) async {
    if (!isAuthenticated || !Platform.isAndroid) return;
    try {
      final fcmToken = token ?? await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await ApiClient(authController: this).patch(
          '${ApiConfig.baseUrl}/users/me',
          body: {'fcm_token': fcmToken},
        );
      }
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    }
  }

  void clearError() { _error = null; notifyListeners(); }
}
