import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AppTrendLineChart extends StatefulWidget {
  final List<TrendPoint> trendPoints;
  final bool isWeekly;
  final String title;
  final Function(bool) onPeriodChanged;
  final List<String> days;

  const AppTrendLineChart({
    super.key,
    required this.trendPoints,
    required this.isWeekly,
    required this.title,
    required this.onPeriodChanged,
    this.days = const ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'],
  });

  @override
  State<AppTrendLineChart> createState() => _AppTrendLineChartState();
}

class _AppTrendLineChartState extends State<AppTrendLineChart> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColors = [
      colorScheme.primary,
      colorScheme.secondary,
    ];
    // Calculate min/max for chart scaling
    final values = widget.trendPoints.map((p) => p.y).toList();
    final maxY = values.isEmpty ? 100000.0 : (values.reduce((a, b) => a > b ? a : b) * 1.2);
    final minY = values.isEmpty ? 0.0 : (values.reduce((a, b) => a < b ? a : b) * 0.8).clamp(0.0, maxY);

    // Calculate interval based on max value
    double interval = 100000;
    if (maxY > 1000000) {
      interval = 500000;
    } else if (maxY > 500000) {
      interval = 200000;
    } else if (maxY > 100000) {
      interval = 50000;
    } else if (maxY > 50000) {
      interval = 20000;
    } else if (maxY > 10000) {
      interval = 5000;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(24),
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
                  AppHeading(widget.title, size: AppHeadingSize.h3),
                  const SizedBox(height: 4),
                  Text(
                    widget.isWeekly ? 'Pengeluaran minggu ini' : 'Pengeluaran bulan ini',
                    style: TextStyle(
                      color: SavaioTheme.onSurfaceVariantOf(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SavaioTheme.surfaceContainerOf(context),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.2),
                  ),
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
            child: widget.trendPoints.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data tren',
                      style: TextStyle(
                        color: SavaioTheme.onSurfaceVariantOf(context),
                        fontSize: 14,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              // Format as compact currency (e.g., 100K, 1M)
                              String text;
                              if (value >= 1000000) {
                                text = '${(value / 1000000).toStringAsFixed(1)}jt';
                              } else if (value >= 1000) {
                                text = '${(value / 1000).toStringAsFixed(0)}rb';
                              } else {
                                text = value.toStringAsFixed(0);
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: SavaioTheme.onSurfaceVariantOf(context),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < widget.trendPoints.length) {
                                // Weekly mode: SEN-MIN, Monthly mode: M1-M4
                                String label;
                                if (widget.isWeekly) {
                                  const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
                                  label = (index < days.length) ? days[index] : '${index + 1}';
                                } else {
                                  label = 'M${index + 1}';
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: SavaioTheme.onSurfaceVariantOf(context),
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
                          getTooltipColor: (_) => SavaioTheme.surfaceContainerHighestOf(context),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                SavaioTheme.formatCurrency(spot.y, currency: context.watch<AuthController>().currency),
                                TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: widget.trendPoints.map((p) => FlSpot(p.x, p.y)).toList(),
                          isCurved: true,
                          gradient: LinearGradient(colors: gradientColors),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: colorScheme.primary,
                                strokeWidth: 2,
                                strokeColor: Theme.of(context).scaffoldBackgroundColor,
                              );
                            },
                          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SavaioTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? SavaioTheme.surfaceContainerHighOf(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : SavaioTheme.onSurfaceVariantOf(context),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}