import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_badge.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AppHeroAnalysisCard extends StatefulWidget {
  final HeroVM vm;

  const AppHeroAnalysisCard({
    super.key,
    required this.vm,
  });

  @override
  State<AppHeroAnalysisCard> createState() => _AppHeroAnalysisCardState();
}

class _AppHeroAnalysisCardState extends State<AppHeroAnalysisCard> {
  int touchedIndex = -1;

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
            SavaioTheme.formatCurrency(widget.vm.averageAmount),
            size: AppHeadingSize.h1,
          ),
          const SizedBox(height: SavaioTheme.spacingM),
          AppBadge(
            label: '${widget.vm.budgetPercentage.toStringAsFixed(0)}% ${widget.vm.isBelowBudget ? 'BELOW' : 'ABOVE'} BUDGET',
            icon: widget.vm.isBelowBudget ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            variant: widget.vm.isBelowBudget ? AppBadgeVariant.success : AppBadgeVariant.error,
          ),
          const SizedBox(height: SavaioTheme.spacing2xl),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (widget.vm.dailyValues.isEmpty 
                    ? 1.0 
                    : widget.vm.dailyValues.reduce((a, b) => a > b ? a : b).clamp(1.0, 5.0) * 1.2),
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
                        '${(rod.toY * 100).toStringAsFixed(0)}%',
                        TextStyle(
                          color: rod.toY > 1.0 ? SavaioTheme.error : SavaioTheme.primary,
                          fontWeight: FontWeight.bold,
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
                                color: isTouched ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
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
                barGroups: widget.vm.dailyValues.asMap().entries.map((entry) {
                  final isMax = entry.value == widget.vm.dailyValues.reduce((a, b) => a > b ? a : b);
                  final isTouched = entry.key == touchedIndex;
                  final isOverBudget = entry.value > 1.0;
                  
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.clamp(0.05, 5.0),
                        gradient: isOverBudget 
                            ? SavaioTheme.errorGradient 
                            : ((isMax || isTouched) ? SavaioTheme.primaryGradient : null),
                        color: (isOverBudget || isMax || isTouched) 
                            ? null 
                            : SavaioTheme.secondary.withValues(alpha: 0.4),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 1.0,
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
        ],
      ),
    );
  }
}
