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
  List<Transaction>? _transactions;
  List<Map<String, dynamic>>? _monthlySummary;
  bool _isLoading = false;

  // --- Getters ---
  AppData? get dashboardData => _dashboardData;
  Map<String, dynamic>? get spendingTarget => _spendingTarget;
  Map<String, String>? get userProfile => _userProfile;
  List<Transaction>? get transactions => _transactions;
  List<Map<String, dynamic>>? get monthlySummary => _monthlySummary;
  bool get isLoading => _isLoading;
  
  void setTransactions(List<Transaction> txs) {
    _transactions = txs;
    notifyListeners();
  }

  Future<void> fetchAllData() async {
    _setLoading(true);
    try {
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

  Future<void> loadInitialData() async {
    _setLoading(true);
    try {
      // Start all requests in parallel
      final dashboardFuture = _repository.getDashboardData();
      final targetFuture = _repository.getSpendingTarget();
      final profileFuture = _repository.getUserProfile();
      final summaryFuture = _repository.getMonthlySummary();

      // Handle each result as it arrives to update UI incrementally
      dashboardFuture.then((data) {
        _dashboardData = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error dashboard: $e");
      });

      targetFuture.then((data) {
        _spendingTarget = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error target: $e");
      });

      profileFuture.then((data) {
        _userProfile = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error profile: $e");
      });

      summaryFuture.then((data) {
        _monthlySummary = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error summary: $e");
      });

      // Wait for at least the essential dashboard data before hiding initial loading
      try {
        await dashboardFuture;
      } catch (e) {
        debugPrint("Essential data failed: $e");
      }
    } catch (e) {
      debugPrint("Error loading initial data: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTransactions({String? month}) async {
    _setLoading(true);
    try {
      _transactions = await _repository.getTransactions(month: month);
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      _transactions = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMonthlySummary() async {
    _setLoading(true);
    try {
      _monthlySummary = await _repository.getMonthlySummary();
    } catch (e) {
      debugPrint("Error fetching monthly summary: $e");
      _monthlySummary = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(String id) async {
    final success = await _repository.deleteTransaction(id);
    if (success) {
      await fetchAllData();
      if (_transactions != null) {
        _transactions = _transactions!.where((t) => t.id != id).toList();
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> updateProfile({required String fullName}) async {
    final success = await _repository.updateProfile(fullName: fullName);
    if (success) {
      await fetchAllData();
    }
    return success;
  }

  Future<void> updateSpendingTarget(double amount, String period) async {
    _setLoading(true);
    final success = await _repository.saveSpendingTarget(amount: amount, period: period);
    if (success) {
      await fetchAllData();
    } else {
      _setLoading(false);
    }
  }

  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
  }) async {
    _setLoading(true);
    final success = await _repository.addTransaction(title: title, amount: amount, category: category, type: type);
    if (success) {
      await Future.wait([
        fetchAllData(),
        fetchTransactions(),
      ]);
    }
    _setLoading(false);
    return success;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    // Use microtask to avoid "setState during build" if fetch completes too fast
    Future.microtask(() => notifyListeners());
  }
}
