import 'package:savaio/models/budget_model.dart';
import 'package:savaio/repositories/data_sources/remote/budget_remote_data_source.dart';

class BudgetRepository {
  final BudgetRemoteDataSource _remoteDataSource;
  BudgetModel? _cachedTarget;

  BudgetRepository(this._remoteDataSource);

  Future<List<BudgetModel>> getAllBudgets() {
    return _remoteDataSource.getAllBudgets();
  }

  Future<BudgetModel> getSpendingTarget() async {
    try {
      final budgets = await _remoteDataSource.getAllBudgets();
      BudgetModel target;
      if (budgets.isNotEmpty) {
        target = budgets.firstWhere(
          (b) => b.category == 'All' || b.category == 'Total',
          orElse: () => budgets[0],
        );
      } else {
        target = BudgetModel(id: '', amount: 0.0, periodType: 'monthly', month: '', category: 'All');
      }
      _cachedTarget = target;
      return target;
    } catch (e) {
      if (_cachedTarget != null) return _cachedTarget!;
      rethrow;
    }
  }

  Future<bool> saveBudget({
    required double amount,
    required String periodType,
    String category = 'All',
    String? month,
  }) {
    return _remoteDataSource.saveBudget(
      amount: amount,
      period: periodType,
      category: category,
      month: month,
    );
  }
}
