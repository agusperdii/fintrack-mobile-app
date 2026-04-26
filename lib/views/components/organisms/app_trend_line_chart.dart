import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../atoms/app_heading.dart';
import '../molecules/app_segment_toggle_button.dart';

class AppTrendLineChart extends StatelessWidget {
  final String title;
  final List<String> days;
  final int activeDayIndex;
  final bool isWeekly;
  final Function(bool) onPeriodChanged;

  const AppTrendLineChart({
    super.key,
    required this.title,
    this.days = const ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'],
    this.activeDayIndex = 3,
    this.isWeekly = true,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeading(title, size: AppHeadingSize.h3),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: KineticVaultTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSegmentToggleButton(
                      label: 'Minggu Ini', 
                      isActive: isWeekly, 
                      onTap: () => onPeriodChanged(true)
                    ),
                    AppSegmentToggleButton(
                      label: 'Bulan Ini', 
                      isActive: !isWeekly, 
                      onTap: () => onPeriodChanged(false)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          final isToday = index == activeDayIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[index],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 1),
                      FlSpot(2, 4),
                      FlSpot(3, 2),
                      FlSpot(4, 5),
                      FlSpot(5, 3),
                      FlSpot(6, 4),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [KineticVaultTheme.primary, KineticVaultTheme.secondary],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (index == activeDayIndex) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: KineticVaultTheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        }
                        return FlDotCirclePainter(radius: 0);
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          KineticVaultTheme.primary.withValues(alpha: 0.3),
                          KineticVaultTheme.secondary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
