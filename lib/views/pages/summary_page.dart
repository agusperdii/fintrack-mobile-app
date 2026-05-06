import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/summary_utils.dart';
import 'package:savaio/controllers/analytics_controller.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/molecules/app_weekly_summary_item.dart';
import 'package:savaio/views/pages/all_transactions_page.dart';
import 'package:savaio/models/monthly_summary_model.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnalyticsController>();
    final summary = controller.monthlySummary;
    
    // Find max transaction count across ALL data for relative scaling
    final maxTxCount = summary != null ? SummaryUtils.getMaxTransactionCount(summary) : 0;

    // Group summary by year using Utility
    final Map<String, List<MonthlySummaryModel>> groupedSummary = 
        summary != null ? SummaryUtils.groupByYear(summary) : {};

    final sortedYears = groupedSummary.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: const AppHeader(
        title: 'Ringkasan Transaksi',
        showNotification: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchMonthlySummary(),
        color: SavaioTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _ArchiveHero(monthCount: summary?.length ?? 0),
              const SizedBox(height: 32),
              
              if (summary != null && summary.isNotEmpty)
                ...sortedYears.map((year) {
                  final yearItems = groupedSummary[year]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _YearGroupHeader(year: year, color: SavaioTheme.secondary),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: yearItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = yearItems[index];
                          final monthStr = item.month; // e.g., "2026-04"
                          final count = item.transactionCount;
                          
                          // Relative progress calculation based on transaction count
                          final progress = SummaryUtils.calculateRelativeProgress(count, maxTxCount);

                          return AppWeeklySummaryItem(
                            title: SummaryUtils.formatMonthYear(monthStr),
                            amount: '$count Transaksi',
                            progress: progress, 
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllTransactionsPage(initialMonth: monthStr),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                })
              else if (summary != null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('Belum ada riwayat bulanan', style: TextStyle(color: SavaioTheme.onSurfaceVariant)),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator(color: SavaioTheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveHero extends StatelessWidget {
  final int monthCount;
  const _ArchiveHero({required this.monthCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 20,
        color: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeading(
                  'TOTAL ARCHIVIST',
                  size: AppHeadingSize.caption,
                  color: SavaioTheme.onSurfaceVariant,
                  isBold: true,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AppHeading('$monthCount', size: AppHeadingSize.h1),
                    const AppHeading('.', size: AppHeadingSize.h1, color: SavaioTheme.primary),
                    const AppHeading('Bulan', size: AppHeadingSize.h2),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SavaioTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, size: 12, color: SavaioTheme.tertiary),
                  SizedBox(width: 6),
                  Text(
                    'AES-256',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: SavaioTheme.onSurface,
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
