import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../organisms/app_header.dart';
import '../organisms/app_hero_analysis_card.dart';
import '../organisms/app_smart_insight_card.dart';
import '../organisms/app_category_card.dart';
import '../organisms/app_trend_line_chart.dart';
import '../molecules/app_section_header.dart';
import '../molecules/app_editorial_header.dart';
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
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: const AppHeader(title: 'Analisa'),
      body: SingleChildScrollView(
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
            const AppHeroAnalysisCard(
              averageAmount: 125000,
              budgetPercentage: 12,
              dailyValues: [0.4, 0.65, 0.45, 0.9, 0.55, 0.7, 0.35],
            ),
            
            const SizedBox(height: 20),

            // Smart Insight (Organism)
            AppSmartInsightCard(
              title: 'Wawasan Pintar',
              description: 'Pengeluaran transportasi Anda turun 15% minggu ini. Anda berada di jalur yang tepat untuk menabung lebih banyak bulan ini.',
              buttonLabel: 'DETAIL PENGHEMATAN',
              onTap: () => _navigateToPlaceholder('Detail Penghematan'),
            ),

            const SizedBox(height: 32),

            // Category Breakdown Section
            const AppSectionHeader(
              title: 'Breakdown Kategori',
              actionLabel: 'Lihat Semua',
              onActionTap: null, // Fixed to use onActionTap properly if needed
            ),
            const SizedBox(height: 20),
            
            AppCategoryCard(
              icon: Icons.directions_car,
              title: 'Transportasi',
              amount: 'Rp850.000',
              progress: 0.65,
              limit: 'Batas: Rp1.300.000',
              status: 'Aman',
              accentColor: KineticVaultTheme.primary,
              onTap: () => _navigateToPlaceholder('Analisa Transportasi'),
            ),
            const SizedBox(height: 16),
            AppCategoryCard(
              icon: Icons.restaurant,
              title: 'Makanan',
              amount: 'Rp1.420.000',
              progress: 0.88,
              limit: 'Batas: Rp1.500.000',
              status: 'Hampir Habis',
              accentColor: KineticVaultTheme.secondary,
              onTap: () => _navigateToPlaceholder('Analisa Makanan'),
            ),
            const SizedBox(height: 16),
            AppCategoryCard(
              icon: Icons.category,
              title: 'Lainnya',
              amount: 'Rp320.000',
              progress: 0.32,
              limit: 'Batas: Rp1.000.000',
              status: 'Stabil',
              accentColor: KineticVaultTheme.tertiary,
              onTap: () => _navigateToPlaceholder('Analisa Lainnya'),
            ),

            const SizedBox(height: 32),

            // Weekly Trend Visualization (Organism)
            AppTrendLineChart(
              title: 'Tren Ledger',
              onToggle: () => _navigateToPlaceholder('Filter Tren'),
            ),
          ],
        ),
      ),
    );
  }
}
