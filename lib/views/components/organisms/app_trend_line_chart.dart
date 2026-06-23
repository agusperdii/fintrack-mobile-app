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
    
    // 1. Kalkulasi Min & Max yang lebih aman
    final values = widget.trendPoints.map((p) => p.y).toList();
    // Beri ruang 20% di atas agar titik tertinggi tidak menabrak batas atas chart
    final maxY = values.isEmpty ? 100000.0 : (values.reduce((a, b) => a > b ? a : b) * 1.2);
    // Best Practice UI/UX untuk chart pengeluaran: selalu mulai dari 0 sebagai baseline
    const double minY = 0.0; 

    // 2. Interval Dinamis
    // Membagi chart menjadi 4 bagian horizontal secara dinamis. 
    // Ini memastikan sumbu Y hanya akan me-render maksimal 5 label (0%, 25%, 50%, 75%, 100%)
    // sehingga TIDAK AKAN PERNAH terjadi tabrakan label.
    double interval = maxY > 0 ? (maxY / 4) : 25000.0;

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
                            dashArray: [4, 4], // Opsional: Garis putus-putus terlihat lebih elegan
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
                            reservedSize: 48, // Ruang yang cukup untuk format ringkas
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              // Jangan tampilkan label ganda pada posisi yang sama
                              if (value == maxY && value != meta.max) return const SizedBox.shrink();

                              // 3. Formatting yang lebih bersih
                              String text;
                              if (value >= 1000000000) {
                                text = '${(value / 1000000000).toStringAsFixed(1)}M';
                              } else if (value >= 1000000) {
                                text = '${(value / 1000000).toStringAsFixed(1)}jt';
                              } else if (value >= 1000) {
                                text = '${(value / 1000).toStringAsFixed(0)}rb';
                              } else {
                                text = value.toStringAsFixed(0);
                              }

                              // Menghapus desimal ".0" yang tidak perlu (contoh: "1.0jt" menjadi "1jt")
                              text = text.replaceAll('.0jt', 'jt').replaceAll('.0M', 'M');

                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 11, // Sedikit diperbesar dari 10 ke 11 untuk legibilitas
                                      color: SavaioTheme.onSurfaceVariantOf(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
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
                                String label;
                                if (widget.isWeekly) {
                                  label = (index < widget.days.length) ? widget.days[index] : '${index + 1}';
                                } else {
                                  label = 'M${index + 1}';
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 11,
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
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => SavaioTheme.surfaceContainerHighestOf(context),
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                SavaioTheme.formatCurrency(spot.y, currency: context.watch<AuthController>().currency),
                                TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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
                          curveSmoothness: 0.35, // Membuat kurva sedikit lebih natural
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Hitbox diperbesar sedikit
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
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500, // Medium untuk inaktif agar tidak terlalu tipis
          ),
        ),
      ),
    );
  }
}