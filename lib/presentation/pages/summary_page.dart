import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../atoms/app_heading.dart';
import '../organisms/app_header.dart';
import '../molecules/app_stat_item.dart';
import '../molecules/app_weekly_summary_item.dart';
import 'placeholder_page.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: const AppHeader(title: 'Laporan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceholderPage(featureName: 'Statistik Detail')),
                );
              },
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeading(
                      'TOTAL PENGELUARAN BULAN INI',
                      size: AppHeadingSize.caption,
                      color: KineticVaultTheme.onSurfaceVariant,
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    const AppHeading(
                      'Rp5.200.000',
                      size: AppHeadingSize.h1,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: KineticVaultTheme.outlineVariant),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppStatItem(label: 'Target', value: 'Rp6.000.000'),
                        AppStatItem(label: 'Sisa', value: 'Rp800.000'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const AppHeading(
              'Detail Mingguan',
              size: AppHeadingSize.h3,
            ),
            const SizedBox(height: 16),
            AppWeeklySummaryItem(
              title: 'Minggu 1',
              amount: 'Rp1.200.000',
              progress: 0.8,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceholderPage(featureName: 'Detail Minggu 1')),
                );
              },
            ),
            const SizedBox(height: 12),
            AppWeeklySummaryItem(
              title: 'Minggu 2',
              amount: 'Rp1.500.000',
              progress: 0.9,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceholderPage(featureName: 'Detail Minggu 2')),
                );
              },
            ),
            const SizedBox(height: 12),
            AppWeeklySummaryItem(
              title: 'Minggu 3',
              amount: 'Rp2.500.000',
              progress: 1.2,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceholderPage(featureName: 'Detail Minggu 3')),
                );
              },
            ), 
          ],
        ),
      ),
    );
  }
}
