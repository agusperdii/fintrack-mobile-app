import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/molecules/app_weekly_summary_item.dart';
import 'package:savaio/views/pages/all_transactions_page.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        final summary = provider.monthlySummary;
        
        return Scaffold(
          backgroundColor: SavaioTheme.background,
          appBar: AppHeader(
            title: 'Ringkasan Transaksi',
            showNotification: false,
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.fetchMonthlySummary(),
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
                  
                  if (summary != null && summary.isNotEmpty) ...[
                    // Grouping by year (simplified)
                    const _YearGroupHeader(year: '2026', color: SavaioTheme.secondary),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summary.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = summary[index];
                        final monthStr = item['month']; // e.g., "2026-04"
                        return AppWeeklySummaryItem(
                          title: _formatMonth(monthStr),
                          amount: '${item['count']} Transaksi',
                          progress: 0.7, // Mock progress
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
                  ] else if (summary != null)
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
      },
    );
  }

  String _formatMonth(String monthYear) {
    // Basic formatting for YYYY-MM
    try {
      final parts = monthYear.split('-');
      if (parts.length < 2) return monthYear;
      final months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthIdx = int.parse(parts[1]);
      return "${months[monthIdx]} ${parts[0]}";
    } catch (e) {
      return monthYear;
    }
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
