import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../atoms/ambient_glow.dart';
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
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
      child: Stack(
        children: [
          const Positioned(
            right: -60,
            top: -60,
            child: AmbientGlow(size: 160, color: KineticVaultTheme.primary, opacity: 0.1),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeading(
                'DAILY AVERAGE',
                size: AppHeadingSize.caption,
                color: KineticVaultTheme.onSurfaceVariant,
                isBold: true,
              ),
              const SizedBox(height: 8),
              AppHeading(
                KineticVaultTheme.formatCurrency(averageAmount),
                size: AppHeadingSize.h1,
              ),
              const SizedBox(height: 12),
              AppBadge(
                label: '${budgetPercentage.toStringAsFixed(0)}% BELOW BUDGET',
                icon: Icons.trending_down,
                variant: AppBadgeVariant.success,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: dailyValues.map((val) => _buildBar(val, val == dailyValues.reduce((a, b) => a > b ? a : b))).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'].map((day) {
                  final isToday = day == 'KAM'; // Placeholder logic
                  return AppHeading(
                    day,
                    size: AppHeadingSize.caption,
                    color: isToday ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double factor, bool isHighlighted) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 80 * factor,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          gradient: isHighlighted ? KineticVaultTheme.primaryGradient : null,
          color: isHighlighted ? null : KineticVaultTheme.surfaceContainerHigh,
          boxShadow: isHighlighted ? [
            BoxShadow(color: KineticVaultTheme.primary.withValues(alpha: 0.4), blurRadius: 10)
          ] : null,
        ),
      ),
    );
  }
}
