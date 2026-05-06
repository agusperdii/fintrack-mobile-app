import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/controllers/analytics_controller.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/components/organisms/app_category_card.dart';
import 'package:savaio/views/components/organisms/app_hero_analysis_card.dart';
import 'package:savaio/views/components/organisms/app_smart_insight_card.dart';
import 'package:savaio/views/components/organisms/app_category_pie_chart.dart';
import 'package:savaio/views/components/organisms/app_trend_line_chart.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/pages/spending_target_list_page.dart';
import 'package:savaio/views/pages/spending_target_page.dart';
import 'package:savaio/core/theme/app_theme.dart';

class AnalisaPage extends StatefulWidget {
  const AnalisaPage({super.key});

  @override
  State<AnalisaPage> createState() => _AnalisaPageState();
}

class _AnalisaPageState extends State<AnalisaPage> {
  bool _isWeekly = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _handleRefresh());
  }

  Future<void> _handleRefresh() async {
    final now = DateTime.now();
    final currentMonth = sl.dashboardController.data?.targetPeriod ?? 
        "${now.year}-${now.month.toString().padLeft(2, '0')}";

    await Future.wait([
      sl.dashboardController.fetchDashboardData(),
      sl.budgetController.fetchAll(),
      sl.analyticsController.fetchAll(),
      sl.transactionController.fetchTransactions(month: currentMonth),
    ]);
  }

  Future<void> _handleNavigateToEdit(String categoryName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpendingTargetPage(initialCategory: categoryName),
      ),
    );

    if (result == true && mounted) {
      _handleRefresh(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<AnalyticsController, DashboardController, BudgetController, TransactionController>(
      builder: (context, analytics, dashboard, budget, transactions, child) {
        final vm = analytics.buildAnalysisPageVM(
          isWeekly: _isWeekly,
          dashboard: dashboard,
          budget: budget,
          transactions: transactions,
        );

        return Scaffold(
          backgroundColor: SavaioTheme.background,
          appBar: AppHeader(
            title: 'Analisa Keuangan',
            showNotification: false,
            actions: [
              if (dashboard.isSyncingTransaction)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: SavaioTheme.primary),
                    ),
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: SavaioTheme.primary,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                if (analytics.isLoading && !vm.hasData)
                  const Center(child: CircularProgressIndicator())
                else if (analytics.error != null)
                  Center(child: Text('Error: ${analytics.error}'))
                else ...[
                  // 1. Daily Average Analysis
                  AppHeroAnalysisCard(vm: vm.hero),

                  const SizedBox(height: 32),

                  // 2. Pie Chart (Distribution)
                  if (vm.hasData && vm.pieSegments.isNotEmpty) ...[
                    AppCategoryPieChart(
                      segments: vm.pieSegments,
                      categories: vm.categories,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 3. Category Breakdown
                  AppSectionHeader(
                    title: 'Breakdown Kategori',
                    actionLabel: 'Lihat Semua',
                    onActionTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const SpendingTargetListPage())
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (vm.categories.isEmpty)
                    const Center(child: Text('Belum ada target kategori'))
                  else
                    ...vm.categories.map((categoryVM) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppCategoryCard(
                          vm: categoryVM,
                          onTap: () => _handleNavigateToEdit(categoryVM.rawCategoryName),
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // 4. Trend Analysis
                  AppTrendLineChart(
                    trendPoints: vm.trendPoints,
                    isWeekly: vm.isWeekly,
                    title: 'Tren Pengeluaran',
                    onPeriodChanged: (isWeekly) {
                      setState(() {
                        _isWeekly = isWeekly;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // 5. Smart Insight
                  AppSmartInsightCard(
                    vm: vm.insight,
                    onTap: () {}, // No-op placeholder
                  ),
                ],
                const SizedBox(height: 100), // Bottom spacing
              ],
            ),
          ),
        );
      },
    );
  }
}
