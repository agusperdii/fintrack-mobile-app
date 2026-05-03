import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppTrendLineChart extends StatefulWidget {
  final String title;
  final List<FlSpot>? spots;
  final List<String> days;
  final int activeDayIndex;
  final bool isWeekly;
  final Function(bool) onPeriodChanged;

  const AppTrendLineChart({
    super.key,
    required this.title,
    this.spots,
    this.days = const ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'],
    this.activeDayIndex = 3,
    this.isWeekly = true,
    required this.onPeriodChanged,
  });

  @override
  State<AppTrendLineChart> createState() => _AppTrendLineChartState();
}

class _AppTrendLineChartState extends State<AppTrendLineChart> {
  List<Color> gradientColors = [
    SavaioTheme.primary,
    SavaioTheme.secondary,
  ];

  @override
  Widget build(BuildContext context) {
    final spots = widget.spots ?? const [
      FlSpot(0, 3),
      FlSpot(1, 1),
      FlSpot(2, 4),
      FlSpot(3, 2),
      FlSpot(4, 5),
      FlSpot(5, 3),
      FlSpot(6, 4),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeading(widget.title, size: AppHeadingSize.h3),
                  const SizedBox(height: 4),
                  Text(
                    widget.isWeekly ? 'Pengeluaran 7 hari terakhir' : 'Pengeluaran bulan ini',
                    style: const TextStyle(
                      color: SavaioTheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SavaioTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CompactToggleButton(
                      label: 'M', 
                      isActive: widget.isWeekly, 
                      onTap: () => widget.onPeriodChanged(true)
                    ),
                    _CompactToggleButton(
                      label: 'B', 
                      isActive: !widget.isWeekly, 
                      onTap: () => widget.onPeriodChanged(false)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1.5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: SavaioTheme.outlineVariant.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < widget.days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              widget.days[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: SavaioTheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => SavaioTheme.surfaceContainerHighest,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          SavaioTheme.formatCurrency(spot.y * 100000), // Scaled for display
                          const TextStyle(
                            color: SavaioTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(colors: gradientColors),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: gradientColors
                            .map((color) => color.withValues(alpha: 0.15))
                            .toList(),
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

class _CompactToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CompactToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SavaioTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? SavaioTheme.surfaceContainerHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
