// dashboard_controller.dart
// Controller yang mengelola state data dashboard utama (saldo, ringkasan transaksi,
// status check-in) beserta logika optimistic update untuk transaksi.
import 'package:flutter/material.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/checkin_data.dart';
import 'package:savaio/repositories/dashboard_repository.dart';

// Menggunakan kembali helper notifikasi aman yang sama dari transaction_controller.
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
  bool _isBalanceVisible = true;
  bool _isShowingSavingsBalance = false;
  String? _error;

  AppData? _previousDataSnapshot;

  AppData? get data => _data;
  CheckInStatus? get checkInStatus => _checkInStatus;
  bool get isLoading => _isLoading;
  bool get isSyncingTransaction => _isSyncingTransaction;
  bool get isBalanceVisible => _isBalanceVisible;
  bool get isShowingSavingsBalance => _isShowingSavingsBalance;
  String? get error => _error;

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  void toggleBalanceType() {
    _isShowingSavingsBalance = !_isShowingSavingsBalance;
    notifyListeners();
  }

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

  /// Menerapkan transaksi secara optimistic ke state dashboard lokal.
  void applyTransactionOptimistically(Transaction tx, {bool isExpense = true}) {
    if (_data == null) return;

    _previousDataSnapshot = _data;

    double newIncome = _data!.totalIncome;
    double newExpense = _data!.totalExpense;
    double newSavings = _data!.totalSavings;
    double newTodaySpent = _data!.todaySpent;

    if (tx.type == TransactionType.income) {
      newIncome += tx.amount;
    } else if (tx.type == TransactionType.savings) {
      newSavings += tx.amount;
    } else {
      newExpense += tx.amount;
      final now = DateTime.now();
      if (tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day) {
        newTodaySpent += tx.amount;
      }
    }

    _data = _data!.copyWith(
      balance: newIncome - newExpense - newSavings,
      totalIncome: newIncome,
      totalExpense: newExpense,
      totalSavings: newSavings,
      todaySpent: newTodaySpent,
      recentTransactions: [tx, ..._data!.recentTransactions],
    );

    _safeNotifyListeners(this);
  }

  /// Menghapus transaksi secara optimistic dari state dashboard lokal.
  void applyTransactionRemovalOptimistically(Transaction tx, {bool isExpense = true}) {
    if (_data == null) return;

    _previousDataSnapshot = _data;

    double newIncome = _data!.totalIncome;
    double newExpense = _data!.totalExpense;
    double newSavings = _data!.totalSavings;
    double newTodaySpent = _data!.todaySpent;

    if (tx.type == TransactionType.income) {
      newIncome -= tx.amount;
    } else if (tx.type == TransactionType.savings) {
      newSavings -= tx.amount;
    } else {
      newExpense -= tx.amount;
      final now = DateTime.now();
      if (tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day) {
        newTodaySpent -= tx.amount;
      }
    }

    _data = _data!.copyWith(
      balance: newIncome - newExpense - newSavings,
      totalIncome: newIncome,
      totalExpense: newExpense,
      totalSavings: newSavings,
      todaySpent: newTodaySpent,
      recentTransactions: _data!.recentTransactions.where((t) => t.id != tx.id).toList(),
    );

    _safeNotifyListeners(this);
  }

  /// Memperbarui transaksi secara optimistic di state dashboard lokal.
  void applyTransactionUpdateOptimistically(Transaction oldTx, Transaction newTx) {
    if (_data == null) return;

    _previousDataSnapshot = _data;

    double newIncome = _data!.totalIncome;
    double newExpense = _data!.totalExpense;
    double newSavings = _data!.totalSavings;
    double newTodaySpent = _data!.todaySpent;
    final now = DateTime.now();

    // Kurangi dengan nilai lama
    if (oldTx.type == TransactionType.income) {
      newIncome -= oldTx.amount;
    } else if (oldTx.type == TransactionType.savings) {
      newSavings -= oldTx.amount;
    } else {
      newExpense -= oldTx.amount;
      if (oldTx.date.year == now.year && oldTx.date.month == now.month && oldTx.date.day == now.day) {
        newTodaySpent -= oldTx.amount;
      }
    }

    // Tambahkan dengan nilai baru
    if (newTx.type == TransactionType.income) {
      newIncome += newTx.amount;
    } else if (newTx.type == TransactionType.savings) {
      newSavings += newTx.amount;
    } else {
      newExpense += newTx.amount;
      if (newTx.date.year == now.year && newTx.date.month == now.month && newTx.date.day == now.day) {
        newTodaySpent += newTx.amount;
      }
    }

    final updatedTransactions = _data!.recentTransactions.map((tx) {
      return tx.id == oldTx.id ? newTx : tx;
    }).toList();

    _data = _data!.copyWith(
      balance: newIncome - newExpense - newSavings,
      totalIncome: newIncome,
      totalExpense: newExpense,
      totalSavings: newSavings,
      todaySpent: newTodaySpent,
      recentTransactions: updatedTransactions,
    );

    _safeNotifyListeners(this);
  }

  /// Memperbarui status transaksi dan kemungkinan ID-nya.
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

  /// Mengganti transaksi optimistic (temp-ID) dengan transaksi asli dari API.
  void replaceTransaction(String tempId, Transaction realTx) {
    if (_data == null) return;

    final updated = _data!.recentTransactions.map((t) {
      return t.id == tempId ? realTx : t;
    }).toList();

    _data = _data!.copyWith(recentTransactions: updated);
    _safeNotifyListeners(this);
  }

  /// Mengembalikan state dashboard ke snapshot sebelumnya.
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
