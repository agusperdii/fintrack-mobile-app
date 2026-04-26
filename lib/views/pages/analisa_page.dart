import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/organisms/app_header.dart';
import '../components/organisms/app_hero_analysis_card.dart';
import '../components/organisms/app_smart_insight_card.dart';
import '../components/organisms/app_category_card.dart';
import '../components/organisms/app_trend_line_chart.dart';
import '../components/molecules/app_section_header.dart';
import '../components/molecules/app_editorial_header.dart';
import 'placeholder_page.dart';

class AnalisaPage extends StatefulWidget {
  const AnalisaPage({super.key});

  @override
  State<AnalisaPage> createState() => _AnalisaPageState();
}

class _AnalisaPageState extends State<AnalisaPage> {
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
        
        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: AppHeader(
            title: 'Analisa',
            avatarUrl: provider.userProfile?['avatar'],
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
                  // Editorial Header (Molecule)
                  const AppEditorialHeader(
                    category: 'LAPORAN MINGGUAN',
                    title: 'Analisa Pengeluaran',
                  ),
                  const SizedBox(height: 24),

                  // Hero Analysis Card (Organism)
                  AppHeroAnalysisCard(
                    averageAmount: data != null ? data.totalExpense / 30 : 0.0,
                    budgetPercentage: 12.0, // Mock for now
                    dailyValues: const [0.4, 0.65, 0.45, 0.9, 0.55, 0.7, 0.35],
                  ),
                  
                  const SizedBox(height: 20),

                  // Smart Insight (Organism)
                  AppSmartInsightCard(
                    title: 'Wawasan Pintar',
                    description: data != null && data.totalExpense > 0 
                        ? 'Pengeluaran terbesar Anda adalah pada kategori ${data.analysis.isNotEmpty ? data.analysis.first.label : "Lainnya"}. Pastikan tetap sesuai budget!'
                        : 'Belum ada data pengeluaran yang cukup untuk memberikan wawasan.',
                    buttonLabel: 'DETAIL PENGHEMATAN',
                    onTap: () => _navigateToPlaceholder('Detail Penghematan'),
                  ),

                  const SizedBox(height: 32),

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
                      // Mock progress and limit for now
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppCategoryCard(
                          icon: _getIconForCategory(item.label),
                          title: item.label,
                          amount: KineticVaultTheme.formatCurrency(item.amount),
                          progress: 0.5, // Mock
                          limit: 'Batas: Rp -.---.---',
                          status: 'Stabil',
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
                    onToggle: () => _navigateToPlaceholder('Filter Tren'),
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
