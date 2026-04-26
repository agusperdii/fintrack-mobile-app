import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/organisms/app_header.dart';
import '../components/organisms/app_hero_analysis_card.dart';
import '../components/organisms/app_smart_insight_card.dart';
import '../components/organisms/app_category_card.dart';
import '../components/organisms/app_trend_line_chart.dart';
import '../components/organisms/app_category_pie_chart.dart';
import '../components/molecules/app_section_header.dart';
import 'placeholder_page.dart';

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
        
        // Calculate budget percentage for hero card
        double budgetPercentage = 0.0;
        bool isBelowBudget = true;
        
        final targetAmount = (spendingTarget?['amount'] as num?)?.toDouble() ?? 0.0;
        if (targetAmount > 0 && data != null) {
          budgetPercentage = ((targetAmount - data.totalExpense) / targetAmount) * 100;
          if (budgetPercentage < 0) {
            isBelowBudget = false;
            budgetPercentage = budgetPercentage.abs();
          }
        }

        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: AppHeader(
            title: 'Analisa Pengeluaran',
            showNotification: false,
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            color: KineticVaultTheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Hero Analysis Card (Organism)
                  AppHeroAnalysisCard(
                    averageAmount: (data?.totalExpense ?? 0.0) / 30,
                    budgetPercentage: budgetPercentage,
                    isBelowBudget: isBelowBudget,
                    dailyValues: const [0.4, 0.65, 0.45, 0.9, 0.55, 0.7, 0.35],
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
                          limitText = 'Batas: ${KineticVaultTheme.formatCurrency(budgetAmount)}';
                          status = progress > 1.0 ? 'Over' : (progress > 0.8 ? 'Peringatan' : 'Aman');
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppCategoryCard(
                          icon: _getIconForCategory(item.label),
                          title: item.label,
                          amount: KineticVaultTheme.formatCurrency(item.amount),
                          progress: progress.clamp(0.0, 1.0),
                          limit: limitText,
                          status: status,
                          accentColor: color,
                          onTap: () => _navigateToPlaceholder('Analisa ${item.label}'),
                        ),
                      );
                    })
                  else if (data != null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('Belum ada data kategori', style: TextStyle(color: KineticVaultTheme.onSurfaceVariant)),
                      ),
                    )
                  else
                    const Center(child: CircularProgressIndicator(color: KineticVaultTheme.primary)),

                  const SizedBox(height: 32),

                  // Weekly Trend Visualization (Organism)
                  AppTrendLineChart(
                    title: 'Tren Ledger',
                    isWeekly: _isWeeklyTrend,
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

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'makanan':
        return Icons.restaurant;
      case 'transport':
      case 'transportasi':
        return Icons.directions_car;
      case 'shopping':
      case 'belanja':
        return Icons.shopping_bag;
      case 'bills':
      case 'tagihan':
        return Icons.receipt;
      case 'coffee':
        return Icons.coffee;
      default:
        return Icons.category;
    }
  }
}
