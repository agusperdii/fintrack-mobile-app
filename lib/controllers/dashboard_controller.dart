import 'package:flutter/material.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/checkin_data.dart';
import 'package:savaio/repositories/dashboard_repository.dart';

// Reuse the same safe notification helpers from transaction_controller.
void _safeNotifyListeners(ChangeNotifier notifier) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifier.notifyListeners();
  });
}

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardController(this._repository);

  AppData? _data;
  CheckInStatus? _checkInStatus;
  bool _isLoading = false;
  bool _isSyncingTransaction = false;
  String? _error;

  // Snapshot for rollback
  AppData? _previousDataSnapshot;

  AppData? get data => _data;
  CheckInStatus? get checkInStatus => _checkInStatus;
  bool get isLoading => _isLoading;
  bool get isSyncingTransaction => _isSyncingTransaction;
  String? get error => _error;

  set isSyncingTransaction(bool value) {
    _isSyncingTransaction = value;
    _safeNotifyListeners(this);
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners(this);

    try {
      final results = await Future.wait([
        _repository.getDashboard(),
        _repository.getCheckInStatus(),
      ]);
      _data = results[0] as AppData;
      _checkInStatus = results[1] as CheckInStatus;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners(this);
    }
  }

  /// Optimistically applies a transaction to the local dashboard state.
  void applyTransactionOptimistically(Transaction tx, {bool isExpense = true}) {
    if (_data == null) return;

    // Save snapshot for potential rollback
    _previousDataSnapshot = _data;

    final newIncome = isExpense ? _data!.totalIncome : _data!.totalIncome + tx.amount;
    final newExpense = isExpense ? _data!.totalExpense + tx.amount : _data!.totalExpense;

    _data = _data!.copyWith(
      balance: newIncome - newExpense,
      totalIncome: newIncome,
      totalExpense: newExpense,
      recentTransactions: [tx, ..._data!.recentTransactions],
    );

    _safeNotifyListeners(this);
  }

  /// Optimistically removes a transaction from the local dashboard state.
  void applyTransactionRemovalOptimistically(Transaction tx, {bool isExpense = true}) {
    if (_data == null) return;

    // Save snapshot for potential rollback
    _previousDataSnapshot = _data;

    final newIncome = isExpense ? _data!.totalIncome : _data!.totalIncome - tx.amount;
    final newExpense = isExpense ? _data!.totalExpense - tx.amount : _data!.totalExpense;

    _data = _data!.copyWith(
      balance: newIncome - newExpense,
      totalIncome: newIncome,
      totalExpense: newExpense,
      recentTransactions: _data!.recentTransactions.where((t) => t.id != tx.id).toList(),
    );

    _safeNotifyListeners(this);
  }

  /// Updates a transaction's status and potentially its ID.
  void updateTransactionStatus(String id, SyncStatus status, {String? newId}) {
    if (_data == null) return;

    final updatedTransactions = _data!.recentTransactions.map((tx) {
      if (tx.id == id) {
        return tx.copyWith(
          id: newId ?? tx.id,
          syncStatus: status,
        );
      }
      return tx;
    }).toList();

    _data = _data!.copyWith(recentTransactions: updatedTransactions);
    _safeNotifyListeners(this);
  }

  /// Replaces an optimistic (temp-ID) transaction with the real one from the API.
  void replaceTransaction(String tempId, Transaction realTx) {
    if (_data == null) return;

    final updated = _data!.recentTransactions.map((t) {
      return t.id == tempId ? realTx : t;
    }).toList();

    _data = _data!.copyWith(recentTransactions: updated);
    _safeNotifyListeners(this);
  }

  /// Reverts the dashboard state to the previous snapshot.
  void rollbackTransaction() {
    if (_previousDataSnapshot != null) {
      _data = _previousDataSnapshot;
      _previousDataSnapshot = null;
      _safeNotifyListeners(this);
    }
  }

  Future<CheckInStatus> checkIn() async {
    try {
      final status = await _repository.checkIn();
      if (status.isCheckedInToday) {
        await fetchDashboardData();
      }
      return status;
    } catch (e) {
      debugPrint('Error performing check-in: $e');
      rethrow;
    }
  }
}
