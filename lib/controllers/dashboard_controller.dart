import 'package:flutter/material.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/checkin_data.dart';
import 'package:savaio/repositories/dashboard_repository.dart';

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
    notifyListeners();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getDashboardData(),
        _repository.getCheckInStatus(),
      ]);
      _data = results[0] as AppData;
      _checkInStatus = results[1] as CheckInStatus;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optimistically applies a transaction to the local dashboard state.
  void applyTransactionOptimistically(Transaction tx) {
    if (_data == null) return;
    
    // Save snapshot for potential rollback
    _previousDataSnapshot = _data;

    final isExpense = tx.type == TransactionType.expense;
    
    _data = _data!.copyWith(
      totalIncome: isExpense ? _data!.totalIncome : _data!.totalIncome + tx.amount,
      totalExpense: isExpense ? _data!.totalExpense + tx.amount : _data!.totalExpense,
      recentTransactions: [tx, ..._data!.recentTransactions],
    );
    
    notifyListeners();
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
    notifyListeners();
  }

  /// Reverts the dashboard state to the previous snapshot.
  void rollbackTransaction() {
    if (_previousDataSnapshot != null) {
      _data = _previousDataSnapshot;
      _previousDataSnapshot = null;
      notifyListeners();
    }
  }

  Future<bool> performCheckIn() async {
    try {
      final success = await _repository.performCheckIn();
      if (success) {
        await fetchDashboardData();
      }
      return success;
    } catch (e) {
      debugPrint('Error performing check-in: $e');
      return false;
    }
  }
}
