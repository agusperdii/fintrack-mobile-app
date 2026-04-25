import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/atoms/glass_card.dart';
import '../components/atoms/app_heading.dart';
import '../components/organisms/app_header.dart';
import '../components/molecules/app_editorial_header.dart';
import '../components/molecules/app_weekly_summary_item.dart';
import 'placeholder_page.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        
        return Scaffold(
          backgroundColor: KineticVaultTheme.background,
          appBar: AppHeader(
            title: 'The Kinetic Vault',
            avatarUrl: provider.userProfile?['avatar'],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppEditorialHeader(
                  category: 'Archive Collection',
                  title: 'Ringkasan Transaksi',
                ),
                const SizedBox(height: 20),
                const _ArchiveHero(),
                const SizedBox(height: 32),
                const _YearGroupHeader(year: '2026', color: KineticVaultTheme.secondary),
                const SizedBox(height: 16),
                _buildArchiveList(context, [
                  {'month': 'Maret 2026', 'tx': 1476, 'progress': 0.85},
                  {'month': 'Februari 2026', 'tx': 1242, 'progress': 0.7},
                  {'month': 'Januari 2026', 'tx': 980, 'progress': 0.6},
                ]),
                const SizedBox(height: 32),
                const _YearGroupHeader(year: '2025', color: KineticVaultTheme.outline),
                const SizedBox(height: 16),
                _buildArchiveList(context, [
                  {'month': 'Desember 2025', 'tx': 1104, 'progress': 0.9},
                  {'month': 'November 2025', 'tx': 892, 'progress': 0.5},
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchiveList(BuildContext context, List<Map<String, dynamic>> data) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = data[index];
        return AppWeeklySummaryItem(
          title: item['month'],
          amount: '${item['tx']} Transaksi',
          progress: item['progress'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlaceholderPage(featureName: 'Laporan ${item['month']}')),
            );
          },
        );
      },
    );
  }
}

class _ArchiveHero extends StatelessWidget {
  const _ArchiveHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KineticVaultTheme.primary.withValues(alpha: 0.05),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 20,
        color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeading(
                  'TOTAL ARCHIVIST',
                  size: AppHeadingSize.caption,
                  color: KineticVaultTheme.onSurfaceVariant,
                  isBold: true,
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AppHeading('24', size: AppHeadingSize.h1),
                    AppHeading('.', size: AppHeadingSize.h1, color: KineticVaultTheme.primary),
                    AppHeading('Bulan', size: AppHeadingSize.h2),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KineticVaultTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, size: 12, color: KineticVaultTheme.tertiary),
                  SizedBox(width: 6),
                  Text(
                    'AES-256',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: KineticVaultTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YearGroupHeader extends StatelessWidget {
  final String year;
  final Color color;

  const _YearGroupHeader({required this.year, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppHeading(year, size: AppHeadingSize.h3, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 16),
        Expanded(
          child: Divider(
            color: color.withValues(alpha: 0.15),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
