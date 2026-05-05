import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/organisms/app_hero_analysis_card.dart';
import 'package:savaio/views/components/organisms/app_smart_insight_card.dart';
import 'package:savaio/views/components/organisms/app_category_card.dart';
import 'package:savaio/views/components/organisms/app_trend_line_chart.dart';
import 'package:savaio/views/components/organisms/app_category_pie_chart.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/pages/placeholder_page.dart';
import 'package:savaio/views/pages/spending_target_page.dart';
import 'package:savaio/core/utils/analysis_calculator.dart';

class AnalisaPage extends StatefulWidget {
  const AnalisaPage({super.key});

  @override
  State<AnalisaPage> createState() => _AnalisaPageState();
}

class _AnalisaPageState extends State<AnalisaPage> {
  bool _isWeeklyTrend = true;

  void _navigateToPlaceholder(String feature) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaceholderPage(featureName: feature)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        final data = provider.dashboardData;
        final spendingTarget = provider.spendingTarget;
        final allBudgets = provider.allBudgets;
        final weeklyPulse = provider.weeklyPulse;
        
        // Calculate budget percentage for hero card
        double budgetPercentage = 0.0;
        bool isBelowBudget = true;
        
        final targetAmount = (spendingTarget?['amount'] as num?)?.toDouble() ?? 0.0;
        final dailyBudget = targetAmount / 30;

        if (targetAmount > 0 && data != null) {
          budgetPercentage = AnalysisCalculator.budgetPercentage(targetAmount, data.totalExpense);
          isBelowBudget = AnalysisCalculator.isBelowBudget(targetAmount, data.totalExpense);
          
          // If we want to show "how much left" or "how much over"
          if (isBelowBudget) {
            budgetPercentage = 100 - budgetPercentage;
          } else {
            budgetPercentage = budgetPercentage - 100;
          }
        }

        // Get actual daily expenses from weekly pulse
        List<double> dailyExpenses = [];
        if (weeklyPulse != null && weeklyPulse['values'] is List) {
          dailyExpenses = (weeklyPulse['values'] as List).map((e) => (e as num).toDouble()).toList();
        }

        // Ensure we have exactly 7 values for the chart
        while (dailyExpenses.length < 7) {
          dailyExpenses.add(0.0);
        }
        if (dailyExpenses.length > 7) {
          dailyExpenses = dailyExpenses.sublist(0, 7);
        }

        return Scaffold(
          backgroundColor: SavaioTheme.background,
          appBar: AppHeader(
            title: 'Analisa Pengeluaran',
            showNotification: false,
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            color: SavaioTheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Hero Analysis Card (Organism)
                  AppHeroAnalysisCard(
                    averageAmount: AnalysisCalculator.averageDailyExpense(data?.totalExpense ?? 0),
                    budgetPercentage: budgetPercentage,
                    isBelowBudget: isBelowBudget,
                    dailyValues: AnalysisCalculator.buildDailyValues(dailyExpenses, dailyBudget),
                  ),
                  
                  const SizedBox(height: 20),

                  // Smart Insight (Organism)
                  AppSmartInsightCard(
                    title: 'Wawasan Pintar',
                    description: (data?.totalExpense ?? 0) > 0 
                        ? 'Pengeluaran terbesar Anda adalah pada kategori ${data!.analysis.isNotEmpty ? data.analysis.first.label : "Lainnya"}. Pastikan tetap sesuai budget!'
                        : 'Belum ada data pengeluaran yang cukup untuk memberikan wawasan.',
                    buttonLabel: 'DETAIL PENGHEMATAN',
                    onTap: () => _navigateToPlaceholder('Detail Penghematan'),
                  ),

                  const SizedBox(height: 32),

                  if (data != null && data.analysis.isNotEmpty) ...[
                    AppCategoryPieChart(data: data.analysis),
                    const SizedBox(height: 32),
                  ],

                  // Category Breakdown Section
                  const AppSectionHeader(
                    title: 'Breakdown Kategori',
                    actionLabel: 'Lihat Semua',
                    onActionTap: null,
                  ),
                  const SizedBox(height: 20),
                  
                  if (data != null && data.analysis.isNotEmpty)
                    ...data.analysis.map((item) {
                      final color = Color(int.parse('FF${item.colorHex}', radix: 16));
                      
                      // Find category info from controller for better emoji/naming
                      final categoryInfo = provider.categories.firstWhere(
                        (c) => c['name'].toLowerCase() == item.label.toLowerCase(),
                        orElse: () => {'name': item.label, 'icon': Icons.category},
                      );

                      // Find matching budget for this category
                      final categoryBudget = allBudgets.firstWhere(
                        (b) => b['category'].toString().toLowerCase() == item.label.toLowerCase(),
                        orElse: () => <String, dynamic>{},
                      );

                      double progress = 0.0;
                      String limitText = 'Batas: Rp -.---.---';
                      String status = 'Stabil';

                      if (categoryBudget.isNotEmpty) {
                        final budgetAmount = (categoryBudget['amount'] as num).toDouble();
                        if (budgetAmount > 0) {
                          progress = item.amount / budgetAmount;
                          limitText = 'Batas: ${SavaioTheme.formatCurrency(budgetAmount)}';
                          status = progress > 1.0 ? 'Over' : (progress > 0.8 ? 'Peringatan' : 'Aman');
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppCategoryCard(
                          icon: categoryInfo['icon'],
                          title: categoryInfo['name'],
                          amount: SavaioTheme.formatCurrency(item.amount),
                          progress: progress.clamp(0.0, 1.0),
                          limit: limitText,
                          status: status,
                          accentColor: color,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpendingTargetPage(initialCategory: item.label),
                            ),
                          ),
                        ),
                      );
                    })
                  else if (data != null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('Belum ada data kategori', style: TextStyle(color: SavaioTheme.onSurfaceVariant)),
                      ),
                    )
                  else
                    const Center(child: CircularProgressIndicator(color: SavaioTheme.primary)),

                  const SizedBox(height: 32),

                  // Weekly Trend Visualization (Organism)
                  AppTrendLineChart(
                    title: 'Tren Ledger',
                    isWeekly: _isWeeklyTrend,
                    spots: provider.weeklyPulse != null 
                        ? (provider.weeklyPulse!['values'] as List).asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), (e.value as num).toDouble() / 100000);
                          }).toList()
                        : null,
                    onPeriodChanged: (isWeekly) {
                      setState(() {
                        _isWeeklyTrend = isWeekly;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
