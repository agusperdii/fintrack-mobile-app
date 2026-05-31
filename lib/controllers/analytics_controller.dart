import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/api_config.dart';
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

/// Helper class to aggregate expenses from real transaction data
class ExpenseAggregation {
  final double totalSpent;
  final Map<String, double> byCategory;
  final List<double> dailyValues;
  final int daysInMonth;

  ExpenseAggregation({
    required this.totalSpent,
    required this.byCategory,
    required this.dailyValues,
    required this.daysInMonth,
  });
}

/// Validates if a string is in YYYY-MM format
bool _isValidMonth(String? month) {
  if (month == null || month.isEmpty) return false;
  final parts = month.split('-');
  if (parts.length != 2) return false;
  final year = int.tryParse(parts[0]);
  final monthNum = int.tryParse(parts[1]);
  return year != null && monthNum != null && monthNum >= 1 && monthNum <= 12;
}

/// Gets current month in YYYY-MM format
String _getCurrentMonth() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
}

class AnalyticsController extends ChangeNotifier {
  final AnalyticsRepository _repository;
  final AnalyticsService _service;

  AnalyticsController(this._repository, this._service);

  WeeklyPulseModel? _weeklyPulse;
  List<MonthlySummaryModel>? _monthlySummary;
  Map<String, dynamic>? _rawAnalyticsData;
  int _selectedYear = DateTime.now().year;
  String _summaryCurrency = 'IDR';
  bool _isLoading = false;
  String? _error;

  // Production-grade Caching
  AnalysisPageVM? _cachedVM;
  String? _lastCacheKey;

  WeeklyPulseModel? get weeklyPulse => _weeklyPulse;
  List<MonthlySummaryModel>? get monthlySummary => _monthlySummary;
  int get selectedYear => _selectedYear;
  String get summaryCurrency => _summaryCurrency;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Aggregates real transaction data for the analysis page (Fallback)
  ExpenseAggregation _aggregateTransactions({
    required TransactionController transactions,
    required String month,
  }) {
    final allTransactions = transactions.transactions ?? [];

    // Filter expense transactions for the current month
    final expenseTransactions = allTransactions.where((t) {
      final isExpense = t.type == TransactionType.expense;
      final isInMonth = t.date.toIso8601String().startsWith(month);
      return isExpense && isInMonth;
    }).toList();

    // Calculate total spent
    final totalSpent = expenseTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);

    // Aggregate by category
    final byCategory = <String, double>{};
    for (final t in expenseTransactions) {
      final key = t.category?.id ?? '';
      if (key.isNotEmpty) {
        byCategory[key] = (byCategory[key] ?? 0.0) + t.amount;
      }
    }

    // Calculate daily values for the month
    final now = DateTime.now();
    final year = int.tryParse(month.split('-').first) ?? now.year;
    final monthNum = int.tryParse(month.split('-').last) ?? now.month;
    final daysInMonth = DateTime(year, monthNum + 1, 0).day;

    // Initialize daily values (index = day - 1)
    final dailyTotals = List.filled(daysInMonth, 0.0);
    for (final t in expenseTransactions) {
      final dateOnly = t.date.toIso8601String().split('T').first.split(' ').first;
      final parts = dateOnly.split('-');
      final day = parts.length >= 3 ? (int.tryParse(parts[2]) ?? 0) : 0;
      if (day >= 1 && day <= daysInMonth) {
        dailyTotals[day - 1] += t.amount;
      }
    }

    return ExpenseAggregation(
      totalSpent: totalSpent,
      byCategory: byCategory,
      dailyValues: dailyTotals,
      daysInMonth: daysInMonth,
    );
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getWeeklyPulse(),
        _repository.getYearSummaryRaw(year: _selectedYear),
        _repository.getAnalyticsDataRaw(),
      ]);
      _weeklyPulse = results[0] as WeeklyPulseModel;
      
      final summary = results[1] as YearSummary;
      _monthlySummary = summary.months;
      _summaryCurrency = summary.currency;

      _rawAnalyticsData = results[2] as Map<String, dynamic>;
      invalidateCache();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thin controller method that delegates logic to AnalyticsService
  /// Primarily uses API data, fallbacks to local data if needed
  AnalysisPageVM buildAnalysisPageVM({
    required bool isWeekly,
    required DashboardController dashboard,
    required BudgetController budget,
    required TransactionController transactions,
  }) {
    final dashboardData = dashboard.data;

    // 1. Get current period
    String currentMonth;
    final backendMonth = dashboardData?.targetPeriod;
    if (!_isValidMonth(backendMonth)) {
      currentMonth = _getCurrentMonth();
    } else {
      currentMonth = backendMonth!;
    }

    // 2. Cache check
    final totalTxCount = transactions.transactions?.length ?? 0;
    final cacheKey = '$currentMonth-$isWeekly-$totalTxCount-${_rawAnalyticsData.hashCode}';

    if (_cachedVM != null && _lastCacheKey == cacheKey) {
      return _cachedVM!;
    }

    // 3. Extract data from raw API response (Priority)
    final apiData = _rawAnalyticsData;
    
    if (apiData != null && apiData.containsKey('summary')) {
      // USE API DATA
      final summary = apiData['summary'] as Map<String, dynamic>;
      final period = apiData['period'] as Map<String, dynamic>;
      final monthlyTrend = apiData['monthlyTrend'] as List? ?? apiData['monthly_trend'] as List? ?? [];
      final expensesByCategory = apiData['expensesByCategory'] as List? ?? apiData['expenses_by_category'] as List? ?? [];
      final budgetComparison = apiData['budgetComparison'] as List? ?? apiData['budget_comparison'] as List? ?? [];

      // Find an overall budget if possible, or use 0
      BudgetModel? overallBudget;
      try {
        overallBudget = budget.allBudgets.firstWhere((b) => b.startMonth == currentMonth);
      } catch (_) {}

      final heroVM = _service.parseHeroFromApi(
        summary: summary,
        period: period,
        monthlyTrend: monthlyTrend,
        allCategoryBudget: overallBudget,
      );

      final categoriesVM = _service.parseCategoriesFromApi(budgetComparison);
      
      final spendingBreakdown = _service.parseSpendingBreakdownFromApi(expensesByCategory);

      final trendPoints = _service.parseTrendFromApi(monthlyTrend, isWeekly: isWeekly);

      final pieSegments = _service.parsePieFromApi(expensesByCategory);

      final insight = _service.parseInsightFromApi(apiData['insight'] as Map<String, dynamic>?);

      _cachedVM = AnalysisPageVM(
        hero: heroVM,
        categories: categoriesVM,
        spendingBreakdown: spendingBreakdown,
        insight: insight ?? _service.generateInsight(
          totalSpent: ParserUtils.toDouble(summary['totalExpense'] ?? summary['total_expense']),
          byCategory: {for (var e in expensesByCategory) (e as Map)['categoryName'].toString(): ParserUtils.toDouble(e['total'])},
          budgetTargets: budget.getSpendingTargetsForMonth(
            month: currentMonth,
          ),
        ),
        trendPoints: trendPoints,
        pieSegments: pieSegments,
        isWeekly: isWeekly,
        hasData: ParserUtils.toDouble(summary['totalExpense'] ?? summary['total_expense']) > 0,
      );
    } else {
      // FALLBACK TO LOCAL AGGREGATION
      final expenseData = _aggregateTransactions(
        transactions: transactions,
        month: currentMonth,
      );

      BudgetModel? overallBudget;
      try {
        overallBudget = budget.allBudgets.firstWhere((b) => b.startMonth == currentMonth);
      } catch (_) {}

      final budgetTargets = budget.getSpendingTargetsForMonth(
        month: currentMonth,
      );

      final heroVM = _service.calculateHeroMetrics(
        totalSpent: expenseData.totalSpent,
        allCategoryBudget: overallBudget,
        dailyValues: expenseData.dailyValues,
        daysInMonth: expenseData.daysInMonth,
        month: currentMonth,
      );

      final categoriesVM = _service.calculateCategoryBreakdown(
        budgetTargets: budgetTargets,
        realByCategory: expenseData.byCategory,
      );
      
      // Fallback spending breakdown
      final spendingBreakdown = expenseData.byCategory.entries.map((e) {
        final catName = budget.getCategoryName(e.key);
        final catIcon = budget.getCategoryIcon(e.key);
        return SpendingBreakdownVM(
          categoryId: e.key,
          name: catName,
          emoji: catIcon is String ? catIcon : '📦',
          colorHex: '81ECFF',
          amount: e.value,
          percentage: expenseData.totalSpent > 0 ? (e.value / expenseData.totalSpent * 100) : 0,
          transactionCount: 0,
        );
      }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

      final trendPoints = _service.calculateTrendPoints(
        expenseData.dailyValues,
        isWeekly: isWeekly,
      );

      final pieSegments = _service.buildPieSegmentsFromCategories(
        byCategory: expenseData.byCategory,
        totalSpent: expenseData.totalSpent,
      );

      _cachedVM = AnalysisPageVM(
        hero: heroVM,
        categories: categoriesVM,
        spendingBreakdown: spendingBreakdown,
        insight: _service.generateInsight(
          totalSpent: expenseData.totalSpent,
          byCategory: expenseData.byCategory,
          budgetTargets: budgetTargets,
        ),
        trendPoints: trendPoints,
        pieSegments: pieSegments,
        isWeekly: isWeekly,
        hasData: expenseData.totalSpent > 0,
      );
    }

    _lastCacheKey = cacheKey;
    return _cachedVM!;
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

  Future<void> fetchMonthlySummary({int? year}) async {
    if (year != null) _selectedYear = year;
    _isLoading = true;
    notifyListeners();
    try {
      final summary = await _repository.getYearSummaryRaw(year: _selectedYear);
      _monthlySummary = summary.months;
      _summaryCurrency = summary.currency;
      invalidateCache();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportReport(String month, String format) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _repository.getExportToken(month, format);
      final downloadUrl = '${ApiConfig.baseUrl}/download/$token';
      final url = Uri.parse(downloadUrl);

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Gagal membuka browser untuk download';
      }
    } catch (e) {
      debugPrint('Export failed: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
