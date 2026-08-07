// budget_controller.dart
// Controller yang menangani logika bisnis dan state untuk fitur anggaran (budget)
// bulanan pengguna, termasuk pengambilan, pembaruan optimistic, dan sinkronisasi
// data budget serta kategori ke backend.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savaio/models/budget_model.dart';
import 'package:savaio/models/category_model.dart';
import 'package:savaio/models/app_data.dart' as model;
import 'package:savaio/repositories/budget_repository.dart';
import 'package:savaio/repositories/category_repository.dart';
import 'package:savaio/core/utils/parser_utils.dart';

class SpendingTargetItemVM {
  final String categoryId;
  final String categoryName;
  final IconData? iconData;
  final String? emoji;
  final double target;
  final double spent;
  final double progress;
  final bool isOver;
  final model.SyncStatus syncStatus;
  final bool isBudgetExists;
  /// Nilai yang mungkin: active, warning, exceeded
  final String status;

  SpendingTargetItemVM({
    required this.categoryId,
    required this.categoryName,
    this.iconData,
    this.emoji,
    required this.target,
    required this.spent,
    required this.progress,
    required this.isOver,
    this.syncStatus = model.SyncStatus.synced,
    this.isBudgetExists = true,
    this.status = 'active',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpendingTargetItemVM &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          target == other.target &&
          spent == other.spent &&
          progress == other.progress &&
          isOver == other.isOver &&
          syncStatus == other.syncStatus &&
          isBudgetExists == other.isBudgetExists;

  @override
  int get hashCode => Object.hash(categoryId, target, spent, progress, isOver, syncStatus, isBudgetExists);
}

class BudgetController extends ChangeNotifier {
  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;

  BudgetController(this._budgetRepository, this._categoryRepository);

  List<BudgetModel> _allBudgets = [];
  List<BudgetStatusVM> _budgetStatuses = [];
  List<Map<String, dynamic>> _categories = [];
  
  bool _isFetchingData = false;
  bool _isInitialLoaded = false;
  String? _error;

  final Map<String, Timer> _debounceTimers = {};
  final Map<String, int> _lastWriteId = {};

  List<BudgetModel> get allBudgets => _allBudgets;
  List<BudgetStatusVM> get budgetStatuses => _budgetStatuses;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isFetchingData && !_isInitialLoaded;
  bool get isSyncingAny => _allBudgets.any((b) => b.syncStatus == model.SyncStatus.syncing);
  String? get error => _error;

  double get totalMonthlyBudget => _budgetStatuses.fold(0.0, (sum, item) => sum + item.amount);
  double get totalMonthlySpent => _budgetStatuses.fold(0.0, (sum, item) => sum + item.spent);

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _budgetKey(String categoryId, String? month) =>
      '${categoryId.toLowerCase()}|${month?.toLowerCase() ?? 'all'}';

  BudgetModel? _findBudget(String categoryId, String? month) {
    final searchMonth = month ?? '';
    try {
      return _allBudgets.firstWhere(
        (b) => b.categoryId == categoryId && b.startMonth == searchMonth
      );
    } catch (_) {
      return null;
    }
  }

  void _upsertBudget(BudgetModel item) {
    if (item.categoryId == null) return;
    final index = _allBudgets.indexWhere(
      (b) => b.categoryId == item.categoryId && b.startMonth == item.startMonth
    );
    
    if (index != -1) {
      _allBudgets[index] = item;
    } else {
      _allBudgets.add(item);
    }
    // Buat list baru agar referensi berubah (menjaga immutability untuk deteksi perubahan)
    _allBudgets = [..._allBudgets];
  }

  Future<void> fetchAll({bool silent = false, String? month}) async {
    if (!silent) {
      _isFetchingData = true;
      _error = null;
      
      // FIX 1: Gunakan Future.microtask agar notifyListeners() tertunda
      // sampai Flutter selesai menggambar frame saat ini.
      // Ini mencegah error "setState() or markNeedsBuild() called during build".
      Future.microtask(() {
        notifyListeners();
      });
    }

    try {
      final results = await Future.wait([
        _budgetRepository.getAllBudgets(),
        _categoryRepository.getCategories(),
        _budgetRepository.getBudgetStatus(month: month),
      ], eagerError: false);
      
      final serverBudgets = results[0] as List<BudgetModel>;
      final fetchedCategories = results[1] as List<CategoryModel>;
      _budgetStatuses = results[2] as List<BudgetStatusVM>;
      
      // Logika merge: pertahankan item lokal yang berstatus pending/syncing/failed
      _mergeBudgets(serverBudgets);
      
      _categories = fetchedCategories.map((cat) => <String, dynamic>{
        'id': cat.id,
        'name': cat.name,
        'icon': cat.icon,
        'type': cat.type,
        'isEmoji': true,
        'isDefault': cat.isDefault,
      }).toList();

      _isInitialLoaded = true;
      _logDebug('Fetch completed. Merged budgets: ${_allBudgets.length}');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isFetchingData = false;
      
      // FIX 2: Di sini tidak perlu Future.microtask karena ini dieksekusi 
      // secara asynchronous (setelah 'await Future.wait' selesai),
      // jadi dipastikan tidak bertabrakan dengan proses build.
      notifyListeners();
    }
  }

  void _mergeBudgets(List<BudgetModel> serverBudgets) {
    // Pertahankan item lokal yang belum idle/synced
    final localPending = _allBudgets.where(
      (b) => b.syncStatus != model.SyncStatus.idle && b.syncStatus != model.SyncStatus.synced
    ).toList();

    final Map<String, BudgetModel> mergedMap = {};

    for (var b in serverBudgets) {
      if (b.categoryId != null) {
        mergedMap[_budgetKey(b.categoryId!, b.startMonth)] = b;
      }
    }

    // Timpa dengan data lokal pending (write lokal terakhir yang menang)
    for (var b in localPending) {
       if (b.categoryId != null) {
        mergedMap[_budgetKey(b.categoryId!, b.startMonth)] = b;
      }
    }

    _allBudgets = mergedMap.values.toList();
  }

  List<SpendingTargetItemVM> getSpendingTargetsForMonth({
    required String month, 
  }) {
    final List<SpendingTargetItemVM> items = [];

    // Hanya kategori expense yang relevan untuk fitur budgeting
    final expenseCategories = _categories.where((c) => c['type'] == 'expense').toList();

    for (var cat in expenseCategories) {
      final id = cat['id'] as String;
      final name = cat['name'] as String;

      BudgetStatusVM? status;
      try {
        status = _budgetStatuses.firstWhere((s) => s.categoryId == id && s.startMonth == month);
      } catch (_) {}

      if (status != null) {
        items.add(SpendingTargetItemVM(
          categoryId: id,
          categoryName: name,
          emoji: cat['icon'] as String,
          target: status.amount,
          spent: status.spent,
          progress: status.percentageUsed / 100.0,
          isOver: status.status == 'exceeded',
          syncStatus: model.SyncStatus.synced,
          isBudgetExists: true,
          status: status.status,
        ));
      } else {
        // Fallback untuk kategori yang belum punya budget atau tidak ada di status list
        final budget = _findBudget(id, month);
        final targetAmount = budget?.amount ?? 0.0;

        items.add(SpendingTargetItemVM(
          categoryId: id,
          categoryName: name,
          emoji: cat['icon'] as String,
          target: targetAmount,
          // Nilai spent tidak diketahui jika tidak ada di status list (biasanya ditangani backend)
          spent: 0.0,
          progress: 0.0,
          isOver: false,
          syncStatus: budget?.syncStatus ?? model.SyncStatus.idle,
          isBudgetExists: targetAmount > 0,
        ));
      }
    }

    return items;
  }

  void updateSpendingTargetOptimistic(double amount, {required String categoryId, String? month}) {
    final writeId = DateTime.now().microsecondsSinceEpoch;
    final key = _budgetKey(categoryId, month);
    _lastWriteId[key] = writeId;

    final existing = _findBudget(categoryId, month);
    final updatedBudget = BudgetModel(
      id: existing?.id ?? 'temp_$writeId',
      amount: amount,
      startMonth: month ?? '',
      categoryId: categoryId,
      syncStatus: model.SyncStatus.pending,
    );

    _upsertBudget(updatedBudget);
    notifyListeners();

    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(milliseconds: 500), () {
      _syncSpendingTargetInBackground(
        amount: amount,
        categoryId: categoryId,
        startMonth: month ?? '',
        writeId: writeId,
      );
    });
  }

  Future<void> _syncSpendingTargetInBackground({
    required double amount,
    required String categoryId,
    required String startMonth,
    required int writeId,
  }) async {
    final key = _budgetKey(categoryId, startMonth);
    if ((_lastWriteId[key] ?? 0) > writeId) return;

    _updateSyncStatus(categoryId, startMonth, model.SyncStatus.syncing);

    try {
      final success = await _budgetRepository.saveBudget(
        amount: amount,
        categoryId: categoryId,
        startMonth: startMonth,
      ).timeout(const Duration(seconds: 4));

      if ((_lastWriteId[key] ?? 0) > writeId) return;

      if (success) {
        _updateSyncStatus(categoryId, startMonth, model.SyncStatus.synced);
        _error = null;
        // Refresh status setelah penyimpanan berhasil untuk mendapatkan data spent/remaining terbaru
        _budgetRepository.getBudgetStatus(month: startMonth).then((statusList) {
          _budgetStatuses = statusList;
          notifyListeners();
        });
      }
    } catch (e) {
      _logDebug('Sync failed for $key: $e');
      if ((_lastWriteId[key] ?? 0) <= writeId) {
        _error = 'Gagal menyimpan budget: ${e.toString()}';
        _updateSyncStatus(categoryId, startMonth, model.SyncStatus.failed);
      }
    }
  }

  void _updateSyncStatus(String categoryId, String? month, model.SyncStatus status) {
    final item = _findBudget(categoryId, month);
    if (item != null) {
      _upsertBudget(item.copyWith(syncStatus: status));
      notifyListeners();
    }
  }

  Future<void> retryFailedSyncs() async {
    final failedItems = _allBudgets.where((b) => b.syncStatus == model.SyncStatus.failed).toList();
    for (var item in failedItems) {
      if (item.categoryId != null) {
        updateSpendingTargetOptimistic(
          item.amount, 
          categoryId: item.categoryId!, 
          month: item.startMonth
        );
      }
    }
  }

  Future<String?> addCustomCategory(String name, String icon, {String type = 'expense'}) async {
    if (name.isEmpty || icon.isEmpty) return null;
    
    final searchKey = ParserUtils.normalizeCategory(name);
    try {
      final existing = _categories.firstWhere((c) => 
        ParserUtils.normalizeCategory(c['name'] as String) == searchKey &&
        c['type'].toString().toLowerCase() == type.toLowerCase()
      );
      return existing['id']?.toString();
    } catch (_) {}

    try {
      final newCat = await _categoryRepository.createCategory(name, icon, type: type);
      final catMap = <String, dynamic>{
        'id': newCat.id,
        'name': newCat.name,
        'icon': newCat.icon,
        'type': newCat.type,
        'isEmoji': true,
        'isDefault': newCat.isDefault,
      };
      _categories = [..._categories, catMap];
      notifyListeners();
      return newCat.id;
    } catch (e) {
      _logDebug('Error adding categoryId: $e');
      return null;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final cat = _categories.firstWhere((c) => c['id'] == id);
      if (cat['isDefault'] == true) {
        _error = 'Kategori default tidak bisa dihapus';
        notifyListeners();
        return false;
      }

      await _categoryRepository.deleteCategory(id);
      _categories = _categories.where((c) => c['id'] != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus kategori: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void _logDebug(String message) {
    debugPrint('[BudgetSync] $message');
  }

  dynamic getCategoryIcon(String? categoryId) {
    if (categoryId == null) return Icons.category;
    try {
      final cat = _categories.firstWhere((c) => c['id'] == categoryId);
      return cat['icon'];
    } catch (_) {
      return Icons.category;
    }
  }

  String getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Kategori';
    try {
      final cat = _categories.firstWhere((c) => c['id'] == categoryId);
      return cat['name'] as String;
    } catch (_) {
      return 'Kategori';
    }
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}