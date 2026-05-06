import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savaio/models/budget_model.dart';
import 'package:savaio/models/category_model.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/repositories/budget_repository.dart';
import 'package:savaio/repositories/category_repository.dart';
import 'package:savaio/core/utils/parser_utils.dart';

class SpendingTargetItemVM {
  final String category;
  final IconData? iconData;
  final String? emoji;
  final double target;
  final double spent;
  final double progress;
  final bool isOver;
  final SyncStatus syncStatus;
  final bool isBudgetExists;

  SpendingTargetItemVM({
    required this.category,
    this.iconData,
    this.emoji,
    required this.target,
    required this.spent,
    required this.progress,
    required this.isOver,
    this.syncStatus = SyncStatus.synced,
    this.isBudgetExists = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpendingTargetItemVM &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          target == other.target &&
          spent == other.spent &&
          progress == other.progress &&
          isOver == other.isOver &&
          syncStatus == other.syncStatus &&
          isBudgetExists == other.isBudgetExists;

  @override
  int get hashCode => Object.hash(category, target, spent, progress, isOver, syncStatus, isBudgetExists);
}

class BudgetController extends ChangeNotifier {
  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;

  BudgetController(this._budgetRepository, this._categoryRepository);

  BudgetModel? _spendingTarget;
  List<BudgetModel> _allBudgets = [];
  List<Map<String, dynamic>> _categories = [];
  
  bool _isFetchingData = false;
  bool _isInitialLoaded = false;
  String? _error;

  // Debounce and Concurrency management
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, int> _lastWriteId = {};

  BudgetModel? get spendingTarget => _spendingTarget;
  List<BudgetModel> get allBudgets => _allBudgets;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isFetchingData && !_isInitialLoaded;
  bool get isSyncingAny => _allBudgets.any((b) => b.syncStatus == SyncStatus.syncing);
  String? get error => _error;

  // Helper Key Generator - Uses standard normalization
  String _budgetKey(String category, String? month) =>
      '${ParserUtils.normalizeCategory(category)}|${month?.toLowerCase() ?? 'all'}';

  BudgetModel? _findBudget(String category, String? month) {
    final searchMonth = month ?? '';
    final searchKey = ParserUtils.normalizeCategory(category);
    try {
      return _allBudgets.firstWhere(
        (b) => b.categoryKey == searchKey && b.month == searchMonth
      );
    } catch (_) {
      return null;
    }
  }

  void _upsertBudget(BudgetModel item) {
    final index = _allBudgets.indexWhere(
      (b) => b.categoryKey == item.categoryKey && b.month == item.month
    );
    
    if (index != -1) {
      _allBudgets[index] = item;
    } else {
      _allBudgets.add(item);
    }
    _allBudgets = [..._allBudgets]; // Ensure immutability
  }

  Future<void> fetchAll({bool silent = false}) async {
    if (!silent) {
      _isFetchingData = true;
      _error = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _budgetRepository.getSpendingTarget(),
        _budgetRepository.getAllBudgets(),
        _categoryRepository.getCategories(),
      ], eagerError: false);
      
      final serverTarget = results[0] as BudgetModel;
      final serverBudgets = results[1] as List<BudgetModel>;
      
      // Merge logic: Preserve local pending/syncing/failed items
      _mergeBudgets(serverBudgets);
      
      // Special handling for main spending target if it matches local pending
      if (_spendingTarget?.syncStatus == SyncStatus.idle || _spendingTarget?.syncStatus == SyncStatus.synced) {
        _spendingTarget = serverTarget;
      }

      final fetchedCategories = results[2] as List<CategoryModel>;
      _categories = fetchedCategories.map((cat) => <String, dynamic>{
        'id': cat.id,
        'name': cat.name,
        'icon': cat.icon,
        'isEmoji': true,
      }).toList();

      _isInitialLoaded = true;
      _logDebug('Fetch completed. Merged budgets: ${_allBudgets.length}');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isFetchingData = false;
      notifyListeners();
    }
  }

  void _mergeBudgets(List<BudgetModel> serverBudgets) {
    // Keep local items that are in non-idle/synced states
    final localPending = _allBudgets.where(
      (b) => b.syncStatus != SyncStatus.idle && b.syncStatus != SyncStatus.synced
    ).toList();

    final Map<String, BudgetModel> mergedMap = {};
    
    // 1. Add server data
    for (var b in serverBudgets) {
      mergedMap[_budgetKey(b.category, b.month)] = b;
    }
    
    // 2. Overwrite with local pending (Last local write wins)
    for (var b in localPending) {
      mergedMap[_budgetKey(b.category, b.month)] = b;
    }

    _allBudgets = mergedMap.values.toList();
  }

  List<SpendingTargetItemVM> getSpendingTargetsForMonth({
    required String month, 
    required double Function(String category, String month) getSpentAmount,
  }) {
    final List<SpendingTargetItemVM> items = [];
    
    final allCategories = [
      {'name': 'All', 'icon': Icons.all_inclusive},
      ..._categories,
    ];

    for (var cat in allCategories) {
      final name = cat['name'] as String;
      final budget = _findBudget(name, month) ?? _findBudget(name, null);
      
      final budgetModel = budget ?? BudgetModel(
        id: '', 
        amount: 0.0, 
        periodType: 'monthly', 
        month: month, 
        category: name,
        syncStatus: SyncStatus.idle,
      );

      final targetAmount = budgetModel.amount;
      final spent = getSpentAmount(name, month);
      final progress = targetAmount > 0 ? (spent / targetAmount).clamp(0.0, 1.0) : 0.0;
      
      final icon = cat['icon'];
      items.add(SpendingTargetItemVM(
        category: name,
        iconData: icon is IconData ? icon : null,
        emoji: icon is String ? icon : null,
        target: targetAmount,
        spent: spent,
        progress: progress,
        isOver: spent > targetAmount && targetAmount > 0,
        syncStatus: budgetModel.syncStatus,
        isBudgetExists: budgetModel.isBudgetExists,
      ));
    }

    return items;
  }

  void updateSpendingTargetOptimistic(double amount, String periodType, {String category = 'All', String? month}) {
    final writeId = DateTime.now().microsecondsSinceEpoch;
    final key = _budgetKey(category, month);
    _lastWriteId[key] = writeId;

    final existing = _findBudget(category, month);
    final updatedBudget = BudgetModel(
      id: existing?.id ?? 'temp_$writeId',
      amount: amount,
      periodType: periodType,
      month: month ?? '',
      category: category,
      syncStatus: SyncStatus.pending,
    );

    if (ParserUtils.normalizeCategory(category) == 'all') {
      _spendingTarget = updatedBudget;
    }

    _upsertBudget(updatedBudget);
    notifyListeners();

    // Debounced Sync
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(milliseconds: 500), () {
      _syncSpendingTargetInBackground(
        amount: amount,
        periodType: periodType,
        category: category,
        month: month,
        writeId: writeId,
      );
    });
  }

  Future<void> _syncSpendingTargetInBackground({
    required double amount,
    required String periodType,
    required String category,
    required int writeId,
    String? month,
  }) async {
    final key = _budgetKey(category, month);
    if ((_lastWriteId[key] ?? 0) > writeId) return;

    _updateSyncStatus(category, month, SyncStatus.syncing);

    try {
      final success = await _budgetRepository.saveBudget(
        amount: amount,
        periodType: periodType,
        category: category,
        month: month,
      ).timeout(const Duration(seconds: 4)); // Reduced timeout

      if ((_lastWriteId[key] ?? 0) > writeId) return;

      if (success) {
        _updateSyncStatus(category, month, SyncStatus.synced);
      } else {
        throw Exception('Server failed');
      }
    } catch (e) {
      _logDebug('Sync failed for $key: $e');
      if ((_lastWriteId[key] ?? 0) <= writeId) {
        _updateSyncStatus(category, month, SyncStatus.failed);
      }
    }
  }

  void _updateSyncStatus(String category, String? month, SyncStatus status) {
    bool changed = false;
    final normalizedCategory = ParserUtils.normalizeCategory(category);
    
    if (normalizedCategory == 'all' && _spendingTarget != null) {
      _spendingTarget = _spendingTarget!.copyWith(syncStatus: status);
      changed = true;
    }

    final item = _findBudget(category, month);
    if (item != null) {
      _upsertBudget(item.copyWith(syncStatus: status));
      changed = true;
    }

    if (changed) notifyListeners();
  }

  Future<void> retryFailedSyncs() async {
    final failedItems = _allBudgets.where((b) => b.syncStatus == SyncStatus.failed).toList();
    for (var item in failedItems) {
      updateSpendingTargetOptimistic(
        item.amount, 
        item.periodType, 
        category: item.category, 
        month: item.month
      );
    }
  }

  void _logDebug(String message) {
    debugPrint('[BudgetSync] $message');
  }

  Future<void> addCustomCategory(String name, String icon) async {
    if (name.isEmpty || icon.isEmpty) return;
    
    final searchKey = ParserUtils.normalizeCategory(name);
    if (_categories.any((c) => ParserUtils.normalizeCategory(c['name'] as String) == searchKey)) return;

    try {
      final newCat = await _categoryRepository.addCategory(name, icon);
      _categories = [..._categories, <String, dynamic>{
        'id': newCat.id,
        'name': newCat.name,
        'icon': newCat.icon,
        'isEmoji': true,
      }];
      notifyListeners();
    } catch (e) {
      _logDebug('Error adding category: $e');
    }
  }

  dynamic getCategoryIcon(String categoryName) {
    final searchKey = ParserUtils.normalizeCategory(categoryName);
    final cat = _categories.firstWhere(
      (c) => ParserUtils.normalizeCategory(c['name'] as String) == searchKey,
      orElse: () => <String, dynamic>{'icon': Icons.category},
    );
    return cat['icon'];
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
