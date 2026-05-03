import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppWeeklyPulseChart extends StatelessWidget {
  final double growth;
  final List<double> values; 

  const AppWeeklyPulseChart({
    super.key,
    required this.growth,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    // Find max value for normalization or maxY
    final double maxValue = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final double displayMax = maxValue == 0 ? 1.0 : maxValue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeading(
                    'WEEKLY PULSE',
                    size: AppHeadingSize.caption,
                    color: SavaioTheme.onSurfaceVariant,
                    isBold: true,
                  ),
                  AppHeading(
                    'Growth ${growth >= 0 ? "+" : ""}${growth.toStringAsFixed(1)}%',
                    size: AppHeadingSize.h3,
                    color: growth >= 0 ? SavaioTheme.tertiary : SavaioTheme.error,
                  ),
                ],
              ),
              Icon(Icons.insights, color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.3), size: 18),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: displayMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => SavaioTheme.surfaceContainerHighest,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        SavaioTheme.formatCurrency(rod.toY),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt() % 7],
                            style: const TextStyle(
                              color: SavaioTheme.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 22,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: values.asMap().entries.map((entry) {
                  final isMax = entry.value == maxValue && maxValue > 0;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: isMax ? SavaioTheme.tertiary : SavaioTheme.surfaceContainerHighest,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: displayMax,
                          color: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
