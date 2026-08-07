// budget_donut_card.dart
// Widget molecule berbentuk kartu donut chart yang menampilkan ringkasan
// penggunaan anggaran (budget) dalam bentuk visual lingkaran.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';

class BudgetDonutCard extends StatelessWidget {
  final String title;
  final double spent;
  final double total;
  final Color color;

  const BudgetDonutCard({
    super.key,
    required this.title,
    required this.spent,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (spent / total) : 0.0;
    final displayPercentage = (percentage * 100).clamp(0, 100).toStringAsFixed(0);
    final isOver = spent > total && total > 0;
    final difference = (total - spent).abs();
    final prefixText = isOver ? 'Kelebihan ' : 'Sisa ';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
        border: Border.all(
          color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 90,
            width: 90,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 35,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: isOver ? SavaioTheme.errorOf(context) : color,
                        value: percentage.clamp(0.0, 1.0),
                        radius: 10,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: color.withValues(alpha: 0.1),
                        value: (1.0 - percentage).clamp(0.0, 1.0),
                        radius: 10,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    '$displayPercentage%',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isOver ? SavaioTheme.errorOf(context) : SavaioTheme.onSurfaceOf(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: SavaioTheme.onSurfaceOf(context),
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 12,
                color: SavaioTheme.onSurfaceVariantOf(context),
              ),
              children: [
                TextSpan(text: prefixText),
                TextSpan(
                  text: SavaioTheme.formatCurrencyShorthand(difference),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    color: isOver ? SavaioTheme.errorOf(context) : color,
                  ),
                ),
              ],

            ),
          ),
        ],
      ),
    );
  }
}