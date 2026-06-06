import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/controllers/analytics_controller.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/components/organisms/app_hero_analysis_card.dart';
import 'package:savaio/views/components/organisms/app_smart_insight_card.dart';
import 'package:savaio/views/components/organisms/app_category_pie_chart.dart';
import 'package:savaio/views/components/organisms/app_trend_line_chart.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/pages/spending_target_list_page.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Fetch dashboard data first to get the correct period
    await sl.dashboardController.fetchDashboardData();

    // Get the current month from dashboard data, fallback to current month
    final currentMonth = sl.dashboardController.data?.targetPeriod ??
        "${now.year}-${now.month.toString().padLeft(2, '0')}";

    debugPrint('[AnalisaPage] Using month: $currentMonth');

    // Now fetch all other data in parallel
    await Future.wait([
      sl.budgetController.fetchAll(silent: false, month: currentMonth),
      sl.analyticsController.fetchAll(),
      sl.transactionController.fetchTransactions(month: currentMonth),
    ]);
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
          backgroundColor: SavaioTheme.backgroundOf(context),
          appBar: AppHeader(
            title: 'Analisa Keuangan',
            showNotification: false,
            actions: [
              if (dashboard.isSyncingTransaction)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Theme.of(context).colorScheme.primary,
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
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 3. Spending Breakdown (Replacing old Category Breakdown)
                  if (vm.spendingBreakdown.isNotEmpty) ...[
                    AppSectionHeader(
                      title: 'Proporsi Pengeluaran',
                      actionLabel: 'Atur Budget',
                      onActionTap: () {
                        final currentMonth = sl.dashboardController.data?.targetPeriod ??
                            "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => SpendingTargetListPage(initialMonth: currentMonth))
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ...vm.spendingBreakdown.take(5).map((item) => _SpendingBreakdownTile(item: item)),
                    const SizedBox(height: 16),
                  ],

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

class _SpendingBreakdownTile extends StatelessWidget {
  final SpendingBreakdownVM item;
  const _SpendingBreakdownTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor;
    try {
      accentColor = Color(int.parse('FF${item.colorHex}', radix: 16));
    } catch (_) {
      accentColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SavaioTheme.outlineVariantOf(context).withValues(alpha: isDark ? 0.1 : 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: SavaioTheme.onSurfaceOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.transactionCount} Transaksi',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: SavaioTheme.onSurfaceVariantOf(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                SavaioTheme.formatCurrency(item.amount),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: SavaioTheme.onSurfaceOf(context),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
