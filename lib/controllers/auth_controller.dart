import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:savaio/repositories/finance_repository.dart';

class AuthController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  FinanceRepository? _financeRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Session? _session;
  String? get token => _session?.accessToken;

  bool get isAuthenticated => _session != null;

  User? get currentUser => _session?.user;

  AuthController() {
    _init();
  }

  /// Injects FinanceRepository after initialization to avoid circular dependency
  void setFinanceRepository(FinanceRepository repository) {
    _financeRepository = repository;
  }

  void _init() {
    // Listen to auth state changes to keep the session in sync
    _supabase.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      notifyListeners();
    });
  }

  Future<void> checkAuth() async {
    // Supabase SDK handles persistence automatically
    _session = _supabase.auth.currentSession;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      _session = response.session;

      // Sync with FastAPI backend if login was successful
      if (_session != null && _financeRepository != null) {
        try {
          await _financeRepository!.syncUser();
          debugPrint('Successfully synced user with FastAPI');
        } catch (e) {
          debugPrint('FastAPI Sync Error: $e');
          // We continue even if sync fails, but the app might face 403s later
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return _session != null;
    } catch (e) {
      debugPrint('Supabase Login Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      // SignUp might return a user but no session if email confirmation is enabled
      return response.user != null;
    } catch (e) {
      debugPrint('Supabase Register Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _session = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Supabase Logout Error: $e');
    }
  }
}
