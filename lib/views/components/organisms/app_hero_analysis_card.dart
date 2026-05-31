import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_badge.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AppHeroAnalysisCard extends StatelessWidget {
  final HeroVM vm;

  const AppHeroAnalysisCard({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<AuthController>().currency;
    return GlassCard(
      padding: const EdgeInsets.all(SavaioTheme.spacingXl),
      borderRadius: SavaioTheme.radiusXl,
      child: Row(
        children: [
          Expanded(
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
                  SavaioTheme.formatCurrency(vm.averageAmount, currency: currency),
                  size: AppHeadingSize.h1,
                ),
              ],
            ),
          ),
          const SizedBox(width: SavaioTheme.spacingM),
          AppBadge(
            label: '${vm.budgetPercentage.toStringAsFixed(0)}% ${vm.isBelowBudget ? 'BELOW' : 'ABOVE'} BUDGET',
            icon: vm.isBelowBudget ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            variant: vm.isBelowBudget ? AppBadgeVariant.success : AppBadgeVariant.error,
          ),
        ],
      ),
    );
  }
}
