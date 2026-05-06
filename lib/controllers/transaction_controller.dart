import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/repositories/transaction_repository.dart';
import 'package:savaio/controllers/dashboard_controller.dart';

class TransactionController extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionController(this._repository);

  List<Transaction>? _transactions;
  bool _isLoading = false;
  bool _isAddingTransaction = false;
  bool _isDeletingTransaction = false;
  String? _error;

  List<Transaction>? get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isAddingTransaction => _isAddingTransaction;
  bool get isDeletingTransaction => _isDeletingTransaction;
  String? get error => _error;

  Future<void> fetchTransactions({String? month}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _repository.getTransactions(month: month);
    } catch (e) {
      _error = e.toString();
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a transaction optimistically and returns immediately.
  /// Synchronization happens in the background.
  void addTransactionOptimistic({
    required DashboardController dashboardController,
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  }) {
    final stopwatch = Stopwatch()..start();
    _isAddingTransaction = true;
    notifyListeners();
    
    // Create optimistic transaction
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newTransaction = Transaction(
      id: tempId,
      title: title,
      description: description ?? '',
      amount: amount,
      category: category,
      type: type.toLowerCase() == 'expense' ? TransactionType.expense : TransactionType.income,
      date: (date ?? DateTime.now()).toIso8601String(),
      syncStatus: SyncStatus.pending,
    );

    // 1. Optimistic UI update
    _transactions = [newTransaction, ...?_transactions];
    dashboardController.applyTransactionOptimistically(newTransaction);
    notifyListeners();
    
    debugPrint('Optimistic update took: ${stopwatch.elapsedMilliseconds}ms');

    // 2. Start background sync
    _syncInBackground(
      tempTx: newTransaction,
      dashboardController: dashboardController,
      title: title,
      description: description,
      amount: amount,
      category: category,
      type: type,
      date: date,
    );

    // Stop adding state for UI button after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _isAddingTransaction = false;
      notifyListeners();
    });
  }

  Future<void> _syncInBackground({
    required Transaction tempTx,
    required DashboardController dashboardController,
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  }) async {
    try {
      // 3. API call with timeout (5 seconds)
      final success = await _repository.addTransaction(
        title: title,
        description: description,
        amount: amount,
        category: category,
        type: type,
        date: date,
      ).timeout(const Duration(seconds: 5));

      if (success) {
        debugPrint('Background sync SUCCESS for ${tempTx.id}');
        
        // Update status to synced
        dashboardController.updateTransactionStatus(tempTx.id!, SyncStatus.synced);
        
        // Update local transaction list status
        if (_transactions != null) {
          _transactions = _transactions!.map((tx) {
            return tx.id == tempTx.id ? tx.copyWith(syncStatus: SyncStatus.synced) : tx;
          }).toList();
          notifyListeners();
        }
      } else {
        throw Exception('Server returned failure');
      }
    } catch (e) {
      debugPrint('Background sync FAILED for ${tempTx.id}. Error: $e');
      
      // 4. Update status to failed
      dashboardController.updateTransactionStatus(tempTx.id!, SyncStatus.failed);
      if (_transactions != null) {
        _transactions = _transactions!.map((tx) {
          return tx.id == tempTx.id ? tx.copyWith(syncStatus: SyncStatus.failed) : tx;
        }).toList();
        notifyListeners();
      }

      // Rollback balance if it's a critical error or per user preference
      // Here we just mark as failed and allow retry or manual rollback
      // For now, let's rollback automatically to ensure consistency
      dashboardController.rollbackTransaction();
      
      // Remove the failed transaction from the list
      _transactions = _transactions?.where((tx) => tx.id != tempTx.id).toList();
      notifyListeners();
    }
  }

  Future<bool> deleteTransaction(String id, {DashboardController? dashboardController}) async {
    _isDeletingTransaction = true;
    _error = null;

    final previousTransactions = _transactions != null ? List<Transaction>.from(_transactions!) : null;
    
    // Optimistic Update
    if (_transactions != null) {
      _transactions = _transactions!.where((t) => t.id != id).toList();
      notifyListeners();
    }

    try {
      final success = await _repository.deleteTransaction(id);
      if (!success) throw Exception('Failed to delete transaction');
      
      if (dashboardController != null) {
        await dashboardController.fetchDashboardData();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      _transactions = previousTransactions;
      notifyListeners();
      return false;
    } finally {
      _isDeletingTransaction = false;
      notifyListeners();
    }
  }

  double getSpentAmountFor(String category, String month) {
    if (_transactions == null) return 0.0;
    
    return _transactions!
        .where((t) => t.type == TransactionType.expense)
        .where((t) => t.date.startsWith(month))
        .where((t) => category == 'All' || t.category.toLowerCase() == category.toLowerCase())
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
