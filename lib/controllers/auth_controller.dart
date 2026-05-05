import 'package:flutter/material.dart';
import 'package:savaio/others.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAuthenticated = true; // Default to true for easy mock development
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuth() async {
    // In mock mode, we assume the user is always logged in
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    sl.financeRepository.clearCache();
    notifyListeners();
  }
}
