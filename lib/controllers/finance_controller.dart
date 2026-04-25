import 'package:flutter/material.dart';
import '../models/entities/app_data.dart';
import '../models/repositories/finance_repository.dart';

class FinanceController extends ChangeNotifier {
  final FinanceRepository _repository;

  FinanceController(this._repository);

  // --- States ---
  AppData? _dashboardData;
  Map<String, dynamic>? _spendingTarget;
  Map<String, String>? _userProfile;
  bool _isLoading = false;

  // --- Getters ---
  AppData? get dashboardData => _dashboardData;
  Map<String, dynamic>? get spendingTarget => _spendingTarget;
  Map<String, String>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  // --- Setters / Logic ---
  
  Future<void> fetchAllData() async {
    _setLoading(true);
    try {
      // Fetch data secara paralel
      final results = await Future.wait([
        _repository.getDashboardData(),
        _repository.getSpendingTarget(),
        _repository.getUserProfile(),
      ]);

      _dashboardData = results[0] as AppData;
      _spendingTarget = results[1] as Map<String, dynamic>;
      _userProfile = results[2] as Map<String, String>;
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSpendingTarget(double amount, String period) async {
    // Optimistic Update atau API call
    _spendingTarget = {
      'amount': amount,
      'period': period,
    };
    notifyListeners();
    
    // Di sini nantinya panggil _repository.saveTarget(...)
  }

  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  }) async {
    _setLoading(true);
    final success = await _repository.addTransaction(
      title: title,
      amount: amount,
      category: category,
      type: type,
    );
    
    if (success) {
      // Refresh data dashboard agar SSOT tetap terjaga
      await fetchAllData();
    }
    
    _setLoading(false);
    return success;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
