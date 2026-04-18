import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../organisms/app_header.dart';
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
                    Text(
                      'TOTAL PENGELUARAN BULAN INI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: KineticVaultTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp5.200.000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: KineticVaultTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: KineticVaultTheme.outlineVariant),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryStat('Target', 'Rp6.000.000'),
                        _buildSummaryStat('Sisa', 'Rp800.000'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Detail Mingguan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: KineticVaultTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyCard(context, 'Minggu 1', 'Rp1.200.000', 0.8),
            const SizedBox(height: 12),
            _buildWeeklyCard(context, 'Minggu 2', 'Rp1.500.000', 0.9),
            const SizedBox(height: 12),
            _buildWeeklyCard(context, 'Minggu 3', 'Rp2.500.000', 1.2), // Over budget
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: KineticVaultTheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: KineticVaultTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyCard(BuildContext context, String title, String amount, double progress) {
    final isOverBudget = progress > 1.0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlaceholderPage(featureName: 'Detail $title')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: KineticVaultTheme.onSurface,
                  ),
                ),
                Text(
                  amount,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? KineticVaultTheme.error : KineticVaultTheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              backgroundColor: KineticVaultTheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? KineticVaultTheme.error : KineticVaultTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
