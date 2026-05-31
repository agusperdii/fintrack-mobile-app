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
  String? _error;

  List<Transaction>? get transactions => _transactions;
  MonthSummary? get monthSummary => _monthSummary;
  String get currency => _currency;
  bool get isLoading => _isLoading;
  bool get isAddingTransaction => _isAddingTransaction;
  bool get isDeletingTransaction => _isDeletingTransaction;
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

  /// Drill-down fetch from /summary/{month}/transactions
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

  /// Adds a transaction optimistically and returns immediately.
  /// Synchronization happens in the background.
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
  }) async {
    final stopwatch = Stopwatch()..start();
    _isAddingTransaction = true;
    _safeNotifyListeners(this);

    // Create optimistic transaction
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newTransaction = Transaction(
      id: tempId,
      title: title,
      description: description ?? '',
      amount: amount,
      categoryId: categoryId,
      receiptId: receiptId,
      source: source,
      date: date ?? DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    // 1. Optimistic UI update
    _transactions = [newTransaction, ...?_transactions];
    dashboardController.isSyncingTransaction = true; // Start global sync indicator
    dashboardController.applyTransactionOptimistically(
      newTransaction,
      isExpense: type.toLowerCase() == 'expense',
    );
    _safeNotifyListeners(this);

    debugPrint('Optimistic update took: ${stopwatch.elapsedMilliseconds}ms');

    // 2. Start sync
    try {
      await _syncInBackground(
        tempId: tempId,
        dashboardController: dashboardController,
        title: title,
        description: description,
        amount: amount,
        categoryId: categoryId,
        date: date ?? DateTime.now(),
        receiptId: receiptId,
        source: source,
      );
    } finally {
      _isAddingTransaction = false;
      _safeNotifyListeners(this);
    }

    // Background Sync (Analytics/Notifications)
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
  }) async {
    try {
      // 3. API call with timeout (5 seconds)
      final result = await _repository.createTransaction(
        title: title,
        description: description,
        amount: amount,
        categoryId: categoryId,
        date: date,
        receiptId: receiptId,
        source: source,
      ).timeout(const Duration(seconds: 5));

      if (result.id.isNotEmpty) {
        debugPrint('Background sync SUCCESS for $tempId');
        
        // Update status to synced
        dashboardController.updateTransactionStatus(tempId, SyncStatus.synced);
        dashboardController.isSyncingTransaction = false; // Stop global sync indicator early on success
        
        // Update local transaction list status
        if (_transactions != null) {
          _transactions = _transactions!.map((tx) {
            return tx.id == tempId ? tx.copyWith(syncStatus: SyncStatus.synced) : tx;
          }).toList();
          _safeNotifyListeners(this);
        }
      } else {
        throw Exception('Server returned failure');
      }
    } catch (e) {
      debugPrint('Background sync FAILED for $tempId. Error: $e');

      // 4. Update status to failed
      dashboardController.updateTransactionStatus(tempId, SyncStatus.failed);
      if (_transactions != null) {
        _transactions = _transactions!.map((tx) {
          return tx.id == tempId ? tx.copyWith(syncStatus: SyncStatus.failed) : tx;
        }).toList();
        _safeNotifyListeners(this);
      }

      // Rollback balance if it's a critical error or per user preference
      // Here we just mark as failed and allow retry or manual rollback
      // For now, let's rollback automatically to ensure consistency
      dashboardController.rollbackTransaction();

      // Remove the failed transaction from the list
      _transactions = _transactions?.where((tx) => tx.id != tempId).toList();
      _safeNotifyListeners(this);
    } finally {
      dashboardController.isSyncingTransaction = false; // Stop global sync indicator
    }
  }

  Future<bool> deleteTransaction(String id, {DashboardController? dashboardController}) async {
    _isDeletingTransaction = true;
    if (dashboardController != null) {
      dashboardController.isSyncingTransaction = true;
    }
    _error = null;

    final previousTransactions = _transactions != null ? List<Transaction>.from(_transactions!) : null;

    // 1. Find the transaction for incremental balance update
    Transaction? deletedTx;
    try {
      deletedTx = _transactions?.firstWhere((t) => t.id == id);
    } catch (_) {
      // Not found in current list
    }

    final isExpense = deletedTx?.type == TransactionType.expense;

    // 2. Optimistic Update (List & Balance)
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

      // NO FULL REFRESH NEEDED - We updated incrementally!
      // dashboardController?.fetchDashboardData();

      return true;
    } catch (e) {
      _error = e.toString();

      // 3. Rollback (List & Balance)
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
