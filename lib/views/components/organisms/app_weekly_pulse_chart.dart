import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppWeeklyPulseChart extends StatefulWidget {
  final double growth;
  final List<double> values;

  const AppWeeklyPulseChart({
    super.key,
    required this.growth,
    required this.values,
  });

  @override
  State<AppWeeklyPulseChart> createState() => _AppWeeklyPulseChartState();
}

class _AppWeeklyPulseChartState extends State<AppWeeklyPulseChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Find max value for normalization or maxY
    final double maxValue = widget.values.isEmpty ? 1.0 : widget.values.reduce((a, b) => a > b ? a : b);
    final double displayMax = maxValue == 0 ? 1.0 : maxValue * 1.2; // Add some headroom

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: SavaioTheme.outlineVariant.withValues(alpha: 0.1),
        ),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppHeading(
                        'Growth ${widget.growth >= 0 ? "+" : ""}${widget.growth.toStringAsFixed(1)}%',
                        size: AppHeadingSize.h3,
                        color: widget.growth >= 0 ? SavaioTheme.tertiary : SavaioTheme.error,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        widget.growth >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: widget.growth >= 0 ? SavaioTheme.tertiary : SavaioTheme.error,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SavaioTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: SavaioTheme.primary.withValues(alpha: 0.8),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: displayMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => SavaioTheme.surfaceContainerHighest,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        SavaioTheme.formatCurrency(rod.toY),
                        const TextStyle(
                          color: SavaioTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
                        const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
                        final isTouched = value.toInt() == touchedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            days[value.toInt() % 7],
                            style: TextStyle(
                              color: isTouched ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: widget.values.asMap().entries.map((entry) {
                  final isMax = entry.value == maxValue && maxValue > 0;
                  final isTouched = entry.key == touchedIndex;
                  
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value == 0 ? 0.1 : entry.value,
                        gradient: LinearGradient(
                          colors: isMax 
                              ? [SavaioTheme.tertiary, SavaioTheme.tertiary.withValues(alpha: 0.7)]
                              : isTouched
                                ? [SavaioTheme.primary, SavaioTheme.primary.withValues(alpha: 0.7)]
                                : [SavaioTheme.secondary, SavaioTheme.secondary.withValues(alpha: 0.7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: displayMax,
                          color: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              duration: const Duration(milliseconds: 250),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Tertinggi', SavaioTheme.tertiary),
              const SizedBox(width: 24),
              _buildLegendItem('Harian', SavaioTheme.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: SavaioTheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
