import 'package:flutter/material.dart';
import 'package:savaio/models/weekly_pulse_model.dart';
import 'package:savaio/models/monthly_summary_model.dart';
import 'package:savaio/models/budget_model.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/repositories/analytics_repository.dart';
import 'package:savaio/services/analytics_service.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';
import 'package:savaio/core/utils/parser_utils.dart';

class AnalyticsController extends ChangeNotifier {
  final AnalyticsRepository _repository;
  final AnalyticsService _service;

  AnalyticsController(this._repository, this._service);

  WeeklyPulseModel? _weeklyPulse;
  List<MonthlySummaryModel>? _monthlySummary;
  bool _isLoading = false;
  String? _error;

  // Production-grade Caching
  AnalysisPageVM? _cachedVM;
  String? _lastCacheKey;

  WeeklyPulseModel? get weeklyPulse => _weeklyPulse;
  List<MonthlySummaryModel>? get monthlySummary => _monthlySummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getWeeklyPulse(),
        _repository.getMonthlySummary(),
      ]);
      _weeklyPulse = results[0] as WeeklyPulseModel;
      _monthlySummary = results[1] as List<MonthlySummaryModel>;
      invalidateCache();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thin controller method that delegates logic to AnalyticsService
  AnalysisPageVM buildAnalysisPageVM({
    required bool isWeekly,
    required DashboardController dashboard,
    required BudgetController budget,
    required TransactionController transactions,
  }) {
    final dashboardData = dashboard.data;
    
    // 1. Standardize Month/Period (Explicit error handling)
    final String currentMonth = dashboardData?.targetPeriod ?? '';
    if (currentMonth.isEmpty) {
      return _buildEmptyVM(isWeekly);
    }
    
    // 2. Version-based Cache Key
    final cacheKey = '$currentMonth-$isWeekly-'
        '${dashboardData?.totalExpense}-'
        '${budget.allBudgets.length}-'
        '${transactions.transactions?.length ?? 0}';
    
    if (_cachedVM != null && _lastCacheKey == cacheKey) {
      return _cachedVM!;
    }

    // 3. Delegate to Service for Aggregation
    final totalSpentInMonth = transactions.getSpentAmountFor('all', currentMonth);
    
    final allCategoryBudget = budget.allBudgets.firstWhere(
      (b) => ParserUtils.normalizeCategory(b.category) == 'all' && b.month == currentMonth,
      orElse: () => budget.spendingTarget ?? BudgetModel(
        id: '', 
        amount: 0.0, 
        periodType: 'monthly', 
        month: currentMonth, 
        category: 'All',
        syncStatus: SyncStatus.idle,
      ),
    );

    final budgetTargets = budget.getSpendingTargetsForMonth(
      month: currentMonth, 
      getSpentAmount: transactions.getSpentAmountFor,
    );

    // Build the VM components using the Service
    final heroVM = _service.calculateHeroMetrics(
      totalSpent: totalSpentInMonth,
      allCategoryBudget: allCategoryBudget.isBudgetExists ? allCategoryBudget : null,
      weeklyPulseValues: _weeklyPulse?.values ?? [],
      month: currentMonth,
    );

    final categoriesVM = _service.calculateCategoryBreakdown(
      budgetTargets: budgetTargets,
    );

    final trendPoints = _service.calculateTrendPoints(_weeklyPulse?.values ?? []);
    
    final pieSegments = _service.calculatePieSegments(dashboardData?.analysis ?? []);

    final insight = _service.generateInsight(
      totalSpent: totalSpentInMonth,
      subCategories: budgetTargets,
      rawAnalysis: dashboardData?.analysis ?? [],
    );

    _cachedVM = AnalysisPageVM(
      hero: heroVM,
      categories: categoriesVM,
      insight: insight,
      trendPoints: trendPoints,
      pieSegments: pieSegments,
      isWeekly: isWeekly,
      hasData: true,
    );
    _lastCacheKey = cacheKey;

    return _cachedVM!;
  }

  AnalysisPageVM _buildEmptyVM(bool isWeekly) {
    return AnalysisPageVM(
      hero: HeroVM(
        averageAmount: 0,
        budgetPercentage: 0,
        isBelowBudget: true,
        dailyValues: List.filled(7, 0.0),
        dailyTarget: 0,
      ),
      categories: [],
      insight: AnalysisInsight(
        title: 'Tidak Ada Data',
        description: 'Silakan pilih periode atau tambahkan transaksi untuk memulai analisa.',
      ),
      trendPoints: [],
      pieSegments: [],
      isWeekly: isWeekly,
      hasData: false,
    );
  }

  void invalidateCache() {
    _cachedVM = null;
    _lastCacheKey = null;
  }

  Future<void> fetchWeeklyPulse() async {
    try {
      _weeklyPulse = await _repository.getWeeklyPulse();
      invalidateCache();
      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> fetchMonthlySummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      _monthlySummary = await _repository.getMonthlySummary();
      invalidateCache();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
