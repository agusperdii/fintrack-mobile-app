import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_badge.dart';

class AppHeroAnalysisCard extends StatelessWidget {
  final double averageAmount;
  final double budgetPercentage; 
  final List<double> dailyValues;
  final bool isBelowBudget;

  const AppHeroAnalysisCard({
    super.key,
    required this.averageAmount,
    required this.budgetPercentage,
    required this.dailyValues,
    this.isBelowBudget = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
          padding: const EdgeInsets.all(SavaioTheme.spacingXl),
          borderRadius: SavaioTheme.radiusXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeading(
                'DAILY AVERAGE'.toUpperCase(),
                size: AppHeadingSize.caption,
                color: SavaioTheme.onSurfaceVariant,
                isBold: true,
              ),
              const SizedBox(height: SavaioTheme.spacingS),
              AppHeading(
                SavaioTheme.formatCurrency(averageAmount),
                size: AppHeadingSize.h1,
              ),
              const SizedBox(height: SavaioTheme.spacingM),
              AppBadge(
                label: '${budgetPercentage.toStringAsFixed(0)}% ${isBelowBudget ? 'BELOW' : 'ABOVE'} BUDGET',
                icon: isBelowBudget ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                variant: isBelowBudget ? AppBadgeVariant.success : AppBadgeVariant.error,
              ),
              const SizedBox(height: SavaioTheme.spacing2xl),
              SizedBox(
                height: 120,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => SavaioTheme.surfaceContainerHighest,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${(rod.toY * 100).toStringAsFixed(0)}%',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                              final isToday = index == 3; // Mock today as KAM
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(
                                  days[index],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    color: isToday ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
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
                    barGroups: dailyValues.asMap().entries.map((entry) {
                      final isMax = entry.value == dailyValues.reduce((a, b) => a > b ? a : b);
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.clamp(0.1, 1.0),
                            gradient: isMax ? SavaioTheme.primaryGradient : null,
                            color: isMax ? null : SavaioTheme.surfaceContainerHigh,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 1.0,
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
