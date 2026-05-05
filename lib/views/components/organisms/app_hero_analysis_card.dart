import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_badge.dart';

class AppHeroAnalysisCard extends StatefulWidget {
  final String averageAmountText;
  final double budgetPercentage; 
  final List<double> dailyValues;
  final bool isBelowBudget;
  final String title;
  final String statusText;

  const AppHeroAnalysisCard({
    super.key,
    required this.averageAmountText,
    required this.budgetPercentage,
    required this.dailyValues,
    this.isBelowBudget = true,
    this.title = 'DAILY AVERAGE',
    this.statusText = 'AMAN',
  });

  @override
  State<AppHeroAnalysisCard> createState() => _AppHeroAnalysisCardState();
}

class _AppHeroAnalysisCardState extends State<AppHeroAnalysisCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    double maxVal = widget.dailyValues.fold(0.0, (m, v) => v > m ? v : m);
    double chartMaxY = maxVal > 0 ? maxVal * 1.2 : 100000.0;

    final primaryGradient = LinearGradient(
      colors: [colorScheme.primary, colorScheme.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Semantics(
      container: true,
      label: 'Hero Analysis Card',
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeading(
              widget.title.toUpperCase(),
              size: AppHeadingSize.caption,
              color: colorScheme.onSurfaceVariant,
              isBold: true,
            ),
            const SizedBox(height: 8),
            AppHeading(
              widget.averageAmountText,
              size: AppHeadingSize.h1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            AppBadge(
              label: '${widget.budgetPercentage.toStringAsFixed(0)}% TERPAKAI (${widget.isBelowBudget ? widget.statusText : 'OVER'})',
              icon: widget.isBelowBudget ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
              variant: widget.isBelowBudget ? AppBadgeVariant.success : AppBadgeVariant.error,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
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
                      getTooltipColor: (_) => colorScheme.surfaceContainerHighest,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toStringAsFixed(0),
                          TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
                          final index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            final isTouched = index == touchedIndex;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: Text(
                                days[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                                  color: isTouched ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: widget.dailyValues.asMap().entries.map((entry) {
                    final isMax = entry.value == maxVal && maxVal > 0;
                    final isTouched = entry.key == touchedIndex;
                    
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          gradient: (isMax || isTouched) ? primaryGradient : null,
                          color: (isMax || isTouched) ? null : colorScheme.secondary.withValues(alpha: 0.4),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: chartMaxY,
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
