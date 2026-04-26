import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../atoms/app_heading.dart';
import '../atoms/app_badge.dart';

class AppHeroAnalysisCard extends StatelessWidget {
  final double averageAmount;
  final double budgetPercentage; 
  final List<double> dailyValues;

  const AppHeroAnalysisCard({
    super.key,
    required this.averageAmount,
    required this.budgetPercentage,
    required this.dailyValues,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
          padding: const EdgeInsets.all(KineticVaultTheme.spacingXl),
          borderRadius: KineticVaultTheme.radiusXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeading(
                'DAILY AVERAGE'.toUpperCase(),
                size: AppHeadingSize.caption,
                color: KineticVaultTheme.onSurfaceVariant,
                isBold: true,
              ),
              const SizedBox(height: KineticVaultTheme.spacingS),
              AppHeading(
                KineticVaultTheme.formatCurrency(averageAmount),
                size: AppHeadingSize.h1,
              ),
              const SizedBox(height: KineticVaultTheme.spacingM),
              AppBadge(
                label: '${budgetPercentage.toStringAsFixed(0)}% BELOW BUDGET',
                icon: Icons.trending_down_rounded,
                variant: AppBadgeVariant.success,
              ),
              const SizedBox(height: KineticVaultTheme.spacing2xl),
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: dailyValues.map((val) => _buildBar(val, val == dailyValues.reduce((a, b) => a > b ? a : b))).toList(),
                ),
              ),
              const SizedBox(height: KineticVaultTheme.spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'].map((day) {
                  final isToday = day == 'KAM'; // Placeholder logic
                  return AppHeading(
                    day,
                    size: AppHeadingSize.caption,
                    color: isToday ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
                    isBold: isToday,
                  );
                }).toList(),
              ),
            ],
          ),
        );
  }

  Widget _buildBar(double factor, bool isHighlighted) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 80 * (factor < 0.1 ? 0.1 : factor),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(KineticVaultTheme.radiusXs)),
          gradient: isHighlighted ? KineticVaultTheme.primaryGradient : null,
          color: isHighlighted ? null : KineticVaultTheme.surfaceContainerHigh,
        ),
      ),
    );
  }
}
