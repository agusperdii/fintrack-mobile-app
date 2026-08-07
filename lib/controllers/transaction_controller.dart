// transaction_controller.dart
// Controller yang mengelola state dan logika bisnis transaksi (income, expense,
// savings), termasuk optimistic update, sinkronisasi background ke API, serta
// rollback saat terjadi kegagalan.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/monthly_summary_model.dart';
import 'package:savaio/repositories/transaction_repository.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/core/utils/parser_utils.dart';
import 'package:savaio/core/utils/service_locator.dart';

void _safeNotifyListeners(ChangeNotifier notifier) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifier.notifyListeners();
  });
}

class TransactionController extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionController(this._repository);

  List<Transaction>? _transactions;
  MonthSummary? _monthSummary;
  String _currency = 'IDR';
  bool _isLoading = false;
  bool _isAddingTransaction = false;
  bool _isDeletingTransaction = false;
  bool _isUpdatingTransaction = false;
  String? _error;

  List<Transaction>? get transactions => _transactions;
  MonthSummary? get monthSummary => _monthSummary;
  String get currency => _currency;
  bool get isLoading => _isLoading;
  bool get isAddingTransaction => _isAddingTransaction;
  bool get isDeletingTransaction => _isDeletingTransaction;
  bool get isUpdatingTransaction => _isUpdatingTransaction;
  String? get error => _error;

  Future<void> fetchTransactions({String? month}) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners(this);

    try {
      _transactions = await _repository.getTransactions(month: month);
    } catch (e) {
      _error = e.toString();
      _transactions = [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners(this);
    }
  }

  /// Fetch drill-down dari endpoint /summary/{month}/transactions
  Future<void> fetchMonthTransactions(String month, {int page = 1}) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners(this);

    try {
      final res = await sl.analyticsRepository.getMonthTransactions(month, page: page);
      if (page == 1) {
        _transactions = res.transactions;
      } else {
        _transactions = [...?_transactions, ...res.transactions];
      }
      _monthSummary = res.summary;
      _currency = res.currency;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners(this);
    }
  }

  /// Menambahkan transaksi secara optimistic dan langsung return.
  /// Sinkronisasi ke server dilakukan di background.
  Future<void> createTransactionOptimistic({
    required DashboardController dashboardController,
    required String title,
    String? description,
    required double amount,
    required String categoryId,
    required String type,
    DateTime? date,
    String? receiptId,
    String source = 'manual',
    String fundSource = 'primary',
    bool useOverdraft = false,
  }) async {
    // Validasi tabungan
    if (type.toLowerCase() == 'savings') {
      if (fundSource == 'savings') {
        // TARIK TABUNGAN
        final totalSavings = dashboardController.data?.totalSavings ?? 0.0;
        if (amount > totalSavings) {
          throw Exception('Saldo tabungan tidak mencukupi untuk ditarik.');
        }
      } else {
        // SETOR TABUNGAN
        final currentBalance = dashboardController.data?.balance ?? 0.0;
        if (currentBalance <= 0) {
          throw Exception('Saldo utama habis. Tambahkan pemasukan dahulu sebelum menabung.');
        }
        if (amount > currentBalance) {
          throw Exception('Nominal tabungan melebihi saldo utama.');
        }
      }
    }

    final stopwatch = Stopwatch()..start();
    _isAddingTransaction = true;
    _safeNotifyListeners(this);

    // Mencari metadata kategori untuk optimistic UI
    Category? optimisticCategory;
    try {
      final catData = sl.budgetController.categories.firstWhere((c) => c['id'] == categoryId);
      optimisticCategory = Category(
        id: categoryId,
        name: catData['name'].toString(),
        type: catData['type']?.toString() ?? type.toLowerCase(),
        emoji: catData['icon']?.toString() ?? '📦',
        color: catData['color']?.toString() ?? '#81ECFF',
      );
    } catch (_) {
      // Fallback jika kategori tidak ditemukan secara lokal
      optimisticCategory = Category(
        id: categoryId,
        name: 'Transaksi',
        type: type.toLowerCase(),
        emoji: '📦',
        color: '#81ECFF',
      );
    }

    final double optimisticAmount = (type.toLowerCase() == 'savings' && fundSource == 'savings') ? -amount : amount;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newTransaction = Transaction(
      id: tempId,
      title: title,
      description: description ?? '',
      amount: optimisticAmount,
      categoryId: categoryId,
      receiptId: receiptId,
      source: source,
      date: date ?? DateTime.now(),
      syncStatus: SyncStatus.pending,
      category: optimisticCategory,
    );

    // 1. Update UI secara optimistic
    _transactions = [newTransaction, ...?_transactions];
    dashboardController.isSyncingTransaction = true;
    dashboardController.applyTransactionOptimistically(
      newTransaction,
      isExpense: type.toLowerCase() == 'expense',
    );
    _safeNotifyListeners(this);

    debugPrint('Optimistic update took: ${stopwatch.elapsedMilliseconds}ms');

    // 2. Mulai sinkronisasi di background (fire and forget, tidak di-await)
    _syncInBackground(
      tempId: tempId,
      dashboardController: dashboardController,
      title: title,
      description: description,
      amount: amount,
      categoryId: categoryId,
      date: date ?? DateTime.now(),
      receiptId: receiptId,
      source: source,
      fundSource: fundSource,
      useOverdraft: useOverdraft,
    );

    _isAddingTransaction = false;
    _safeNotifyListeners(this);

    sl.notificationController.fetchAll();
    sl.analyticsController.fetchAll();
  }

  Future<void> _syncInBackground({
    required String tempId,
    required DashboardController dashboardController,
    required String title,
    String? description,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? receiptId,
    required String source,
    required String fundSource,
    required bool useOverdraft,
  }) async {
    try {
      // 3. Panggil API dengan timeout (5 detik)
      final result = await _repository.createTransaction(
        title: title,
        description: description,
        amount: amount,
        categoryId: categoryId,
        date: date,
        receiptId: receiptId,
        source: source,
        fundSource: fundSource,
        useOverdraft: useOverdraft,
      ).timeout(const Duration(seconds: 5));

      if (result.id.isNotEmpty) {
        debugPrint('Background sync SUCCESS for $tempId');

        dashboardController.replaceTransaction(tempId, result);
        // Matikan indikator sync global lebih awal begitu berhasil (tidak menunggu blok finally)
        dashboardController.isSyncingTransaction = false;

        if (_transactions != null) {
          _transactions = _transactions!.map((tx) {
            return tx.id == tempId ? result : tx;
          }).toList();
          _safeNotifyListeners(this);
        }

        // Perbarui budget dan dashboard secara realtime setelah transaksi sukses
        sl.budgetController.fetchAll(silent: true);
        dashboardController.fetchDashboardData();
      } else {
        throw Exception('Server returned failure');
      }
    } catch (e) {
      debugPrint('Background sync FAILED for $tempId. Error: $e');

      // 4. Update status jadi failed
      dashboardController.updateTransactionStatus(tempId, SyncStatus.failed);
      if (_transactions != null) {
        _transactions = _transactions!.map((tx) {
          return tx.id == tempId ? tx.copyWith(syncStatus: SyncStatus.failed) : tx;
        }).toList();
        _safeNotifyListeners(this);
      }

      // Idealnya rollback saldo hanya untuk error kritikal atau sesuai preferensi user,
      // dan cukup ditandai failed agar bisa di-retry/rollback manual. Namun untuk saat
      // ini rollback dilakukan otomatis demi menjaga konsistensi data.
      dashboardController.rollbackTransaction();

      _transactions = _transactions?.where((tx) => tx.id != tempId).toList();
      _safeNotifyListeners(this);
    } finally {
      dashboardController.isSyncingTransaction = false;
    }
  }

  Future<Transaction> updateTransaction({
    required String id,
    DashboardController? dashboardController,
    String? title,
    String? description,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? receiptId,
    String? fundSource,
    bool useOverdraft = false,
  }) async {
    _isUpdatingTransaction = true;
    _error = null;

    if (dashboardController != null) {
      dashboardController.isSyncingTransaction = true;
    }

    _safeNotifyListeners(this);

    Transaction? oldTransaction;

    try {
      oldTransaction = _transactions?.firstWhere((t) => t.id == id);
    } catch (_) {}
    
    if (oldTransaction == null && dashboardController != null && dashboardController.data != null) {
      try {
        oldTransaction = dashboardController.data!.recentTransactions.firstWhere((t) => t.id == id);
      } catch (_) {}
    }

    oldTransaction ??= Transaction(
      id: id,
      title: title ?? '',
      amount: amount ?? 0.0,
      date: date ?? DateTime.now(),
      source: 'manual',
    );

    // Validasi tabungan
    if (oldTransaction.type == TransactionType.savings && dashboardController != null && amount != null) {
      if (fundSource == 'savings' || (fundSource == null && oldTransaction.amount < 0)) {
        // TARIK TABUNGAN
        final totalSavings = dashboardController.data?.totalSavings ?? 0.0;
        double maxWithdrawal = totalSavings;
        if (oldTransaction.amount < 0) maxWithdrawal += oldTransaction.amount.abs();
        
        if (amount > maxWithdrawal) {
          throw Exception('Saldo tabungan tidak mencukupi untuk ditarik.');
        }
      } else {
        // SETOR TABUNGAN
        final currentBalance = dashboardController.data?.balance ?? 0.0;
        double maxAllowed = currentBalance;
        if (oldTransaction.amount > 0) maxAllowed += oldTransaction.amount;

        if (maxAllowed <= 0 && amount > 0) {
          throw Exception('Saldo utama habis. Tambahkan pemasukan dahulu sebelum menabung.');
        }
        if (amount > maxAllowed) {
          throw Exception('Nominal tabungan melebihi saldo utama.');
        }
      }
    }

    final double computedAmount = amount ?? oldTransaction.amount.abs();
    final double optimisticAmount = (oldTransaction.type == TransactionType.savings && fundSource == 'savings')
        ? -computedAmount
        : computedAmount;

    final previousTransactions =
        _transactions != null ? List<Transaction>.from(_transactions!) : null;

    if (_transactions != null) {
      _transactions = _transactions!.map((tx) {
        if (tx.id != id) return tx;

        final newTx = tx.copyWith(
          title: title ?? tx.title,
          description: description ?? tx.description,
          amount: optimisticAmount,
          categoryId: categoryId ?? tx.categoryId,
          receiptId: receiptId ?? tx.receiptId,
          date: date ?? tx.date,
        );
        
        if (dashboardController != null) {
          dashboardController.applyTransactionUpdateOptimistically(tx, newTx);
        }

        return newTx;
      }).toList();

      _safeNotifyListeners(this);
    }

    try {
      final updated = await _repository.updateTransaction(
        id: id,
        title: title,
        description: description,
        amount: amount,
        categoryId: categoryId,
        date: date,
        receiptId: receiptId,
        fundSource: fundSource,
        useOverdraft: useOverdraft,
      );

      if (_transactions != null) {
        _transactions = _transactions!.map((tx) {
          return tx.id == id ? updated : tx;
        }).toList();
      }

      return updated;

    } catch (e) {
      _error = e.toString();

      _transactions = previousTransactions;
      _safeNotifyListeners(this);

      // Melempar error ke UI Form Page agar memunculkan Snackbar merah
      throw Exception(e);
    } finally {
      _isUpdatingTransaction = false;

      if (dashboardController != null) {
        dashboardController.isSyncingTransaction = false;
        sl.budgetController.fetchAll(silent: true);
        dashboardController.fetchDashboardData();
      }

      _safeNotifyListeners(this);
    }
  }

  Future<bool> deleteTransaction(String id, {DashboardController? dashboardController}) async {
    _isDeletingTransaction = true;
    if (dashboardController != null) {
      dashboardController.isSyncingTransaction = true;
    }
    _error = null;

    final previousTransactions = _transactions != null ? List<Transaction>.from(_transactions!) : null;

    // 1. Cari transaksinya untuk update saldo secara incremental
    Transaction? deletedTx;
    try {
      deletedTx = _transactions?.firstWhere((t) => t.id == id);
    } catch (_) {}

    final isExpense = deletedTx?.type == TransactionType.expense;

    // 2. Optimistic update (list & saldo)
    if (_transactions != null) {
      _transactions = _transactions!.where((t) => t.id != id).toList();
      _safeNotifyListeners(this);
    }

    if (deletedTx != null && dashboardController != null) {
      dashboardController.applyTransactionRemovalOptimistically(deletedTx, isExpense: isExpense);
    }

    try {
      final success = await _repository.deleteTransaction(id);
      if (!success) throw Exception('Failed to delete transaction');

      // Refresh data agar budget harian dan bulanan tetap sinkron
      sl.budgetController.fetchAll(silent: true);
      dashboardController?.fetchDashboardData();

      return true;
    } catch (e) {
      _error = e.toString();

      // 3. Rollback (list & saldo)
      _transactions = previousTransactions;
      if (dashboardController != null) {
        dashboardController.rollbackTransaction();
      }
      _safeNotifyListeners(this);
      return false;
    } finally {
      _isDeletingTransaction = false;
      if (dashboardController != null) {
        dashboardController.isSyncingTransaction = false;
      }
      _safeNotifyListeners(this);
    }
  }

  double getSpentAmountFor(String category, String month) {
    if (_transactions == null) return 0.0;
    
    final normalizedSearch = ParserUtils.normalizeCategory(category);
    
    return _transactions!
        .where((t) => t.type == TransactionType.expense)
        .where((t) => t.date.toIso8601String().startsWith(month))
        .where((t) => normalizedSearch == 'all' || t.categoryKey == normalizedSearch)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
