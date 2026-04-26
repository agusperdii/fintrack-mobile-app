import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entities/app_data.dart';
import '../models/repositories/finance_repository.dart';

import '../models/entities/nudge_data.dart';

class FinanceController extends ChangeNotifier {
  final FinanceRepository _repository;

  FinanceController(this._repository);

  // --- States ---
  AppData? _dashboardData;
  Map<String, dynamic>? _spendingTarget;
  List<Map<String, dynamic>> _allBudgets = [];
  Map<String, dynamic>? _weeklyPulse;
  Map<String, String>? _userProfile;
  List<Transaction>? _transactions;
  List<Map<String, dynamic>>? _monthlySummary;
  List<NudgeData> _nudges = [];
  bool _isLoading = false;

  // --- Categories ---
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': '🍔', 'isEmoji': true},
    {'name': 'Salary', 'icon': '💰', 'isEmoji': true},
    {'name': 'Coffee', 'icon': '☕', 'isEmoji': true},
    {'name': 'Transport', 'icon': '🚌', 'isEmoji': true},
    {'name': 'Investment', 'icon': '📈', 'isEmoji': true},
    {'name': 'Education', 'icon': '📚', 'isEmoji': true},
    {'name': 'Gift', 'icon': '🎁', 'isEmoji': true},
    {'name': 'Fun', 'icon': '🎮', 'isEmoji': true},
    {'name': 'Uang Saku', 'icon': '💸', 'isEmoji': true},
    {'name': 'Kost/Sewa', 'icon': '🏠', 'isEmoji': true},
  ];

  // --- Getters ---
  AppData? get dashboardData => _dashboardData;
  Map<String, dynamic>? get spendingTarget => _spendingTarget;
  List<Map<String, dynamic>> get allBudgets => _allBudgets;
  Map<String, dynamic>? get weeklyPulse => _weeklyPulse;
  Map<String, String>? get userProfile => _userProfile;
  List<Transaction>? get transactions => _transactions;
  List<Map<String, dynamic>>? get monthlySummary => _monthlySummary;
  List<NudgeData> get nudges => _nudges;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get categories => _categories;
  
  NudgeData? get latestUnreadNudge {
    if (_nudges.isEmpty) return null;
    try {
      return _nudges.firstWhere((n) => !n.isRead);
    } catch (e) {
      return null;
    }
  }
  
  dynamic getCategoryIcon(String categoryName) {
    final cat = _categories.firstWhere(
      (c) => c['name'].toLowerCase() == categoryName.toLowerCase(),
      orElse: () => {'icon': Icons.category},
    );
    return cat['icon'];
  }

  void setTransactions(List<Transaction> txs) {
    _transactions = txs;
    notifyListeners();
  }

  double getSpentAmountFor(String category, String month) {
    if (_transactions == null) return 0.0;
    
    return _transactions!
        .where((t) => t.type == TransactionType.expense)
        .where((t) => t.date.startsWith(month))
        .where((t) => category == 'All' || t.category.toLowerCase() == category.toLowerCase())
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> fetchAllData() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _repository.getDashboardData(),
        _repository.getSpendingTarget(),
        _repository.getUserProfile(),
        _repository.getAllBudgets(),
        _repository.getWeeklyPulse(),
        _repository.getNudges(),
        loadCategories(),
      ]);
      _dashboardData = results[0] as AppData;
      _spendingTarget = results[1] as Map<String, dynamic>;
      _userProfile = results[2] as Map<String, String>;
      _allBudgets = results[3] as List<Map<String, dynamic>>;
      _weeklyPulse = results[4] as Map<String, dynamic>;
      _nudges = results[5] as List<NudgeData>;
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadInitialData() async {
    _setLoading(true);
    try {
      await loadCategories();
      
      // Start all requests in parallel
      final dashboardFuture = _repository.getDashboardData();
      final targetFuture = _repository.getSpendingTarget();
      final allBudgetsFuture = _repository.getAllBudgets();
      final weeklyPulseFuture = _repository.getWeeklyPulse();
      final profileFuture = _repository.getUserProfile();
      final summaryFuture = _repository.getMonthlySummary();
      final nudgesFuture = _repository.getNudges();

      // Handle each result as it arrives to update UI incrementally
      dashboardFuture.then((data) {
        _dashboardData = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error dashboard: $e");
      });

      nudgesFuture.then((data) {
        _nudges = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error nudges: $e");
      });

      targetFuture.then((data) {
        _spendingTarget = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error target: $e");
      });

      allBudgetsFuture.then((data) {
        _allBudgets = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error all budgets: $e");
      });

      weeklyPulseFuture.then((data) {
        _weeklyPulse = data;
        notifyListeners();
      }).catchError((e) {
        debugPrint("Error weekly pulse: $e");
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

  // --- Category Management ---

  Future<void> fetchNudges() async {
    try {
      _nudges = await _repository.getNudges();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching nudges: $e");
    }
  }

  Future<void> markNudgeAsRead(String id) async {
    final success = await _repository.markNudgeRead(id);
    if (success) {
      final index = _nudges.indexWhere((n) => n.id == id);
      if (index != -1) {
        _nudges[index] = NudgeData(
          id: _nudges[index].id,
          type: _nudges[index].type,
          category: _nudges[index].category,
          message: _nudges[index].message,
          isRead: true,
          createdAt: _nudges[index].createdAt,
        );
        notifyListeners();
      }
    }
  }

  Future<void> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? categoriesJson = prefs.getString('custom_categories');
      if (categoriesJson != null) {
        final List<dynamic> decoded = jsonDecode(categoriesJson);
        final List<Map<String, dynamic>> savedCategories = decoded.cast<Map<String, dynamic>>();
        
        // Merge with default categories, avoiding duplicates by name
        for (var saved in savedCategories) {
          if (!_categories.any((c) => c['name'] == saved['name'])) {
            _categories.add(saved);
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading categories: $e");
    }
    notifyListeners();
  }

  Future<void> addCustomCategory(String name, String icon) async {
    if (name.isEmpty || icon.isEmpty) return;
    
    final newCategory = {'name': name, 'icon': icon, 'isEmoji': true};
    
    // Avoid duplicates
    if (_categories.any((c) => c['name'].toLowerCase() == name.toLowerCase())) {
      return;
    }

    _categories.add(newCategory);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final customOnly = _categories.where((c) {
        // Simple check to identify custom categories: not in the original hardcoded list
        final defaultNames = ['Food', 'Salary', 'Coffee', 'Transport', 'Investment', 'Education', 'Gift', 'Fun', 'Uang Saku', 'Kost/Sewa'];
        return !defaultNames.contains(c['name']);
      }).toList();
      await prefs.setString('custom_categories', jsonEncode(customOnly));
    } catch (e) {
      debugPrint("Error saving category: $e");
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

  Future<bool> updateProfile({required String fullName, String? username}) async {
    final success = await _repository.updateProfile(fullName: fullName, username: username);
    if (success) {
      await fetchAllData();
    }
    return success;
  }

  Future<bool> updatePassword({required String currentPassword, required String newPassword}) async {
    final success = await _repository.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
    return success;
  }

  Future<void> updateSpendingTarget(double amount, String period, {String category = 'All', String? month}) async {
    _setLoading(true);
    final success = await _repository.saveSpendingTarget(amount: amount, period: period, category: category, month: month);
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
    DateTime? date,
  }) async {
    _setLoading(true);
    final success = await _repository.addTransaction(
      title: title,
      amount: amount,
      category: category,
      type: type,
      date: date,
    );
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
