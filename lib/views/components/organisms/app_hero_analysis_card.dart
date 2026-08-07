// app_hero_analysis_card.dart
// Kartu ringkasan analisis yang menampilkan rata-rata pengeluaran harian
// beserta badge status terhadap budget (di atas/di bawah budget).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/controllers/auth_controller.dart';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SavaioTheme.spacingXl),
      decoration: BoxDecoration(
        color: SavaioTheme.primaryOf(context).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
        border: Border.all(
          color: SavaioTheme.primaryOf(context).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SavaioTheme.primaryOf(context).withValues(alpha: 0.05),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Average',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: SavaioTheme.onSurfaceVariantOf(context),
                  ),
                ),
                const SizedBox(height: SavaioTheme.spacingS),
                Text(
                  SavaioTheme.formatCurrency(vm.averageAmount, currency: currency),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: SavaioTheme.onSurfaceOf(context),
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SavaioTheme.spacingM),
          AppBadge(
            label: '${vm.budgetPercentage.toStringAsFixed(0)}% ${vm.isBelowBudget ? 'Below' : 'Above'} Budget',
            icon: vm.isBelowBudget ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            variant: vm.isBelowBudget ? AppBadgeVariant.success : AppBadgeVariant.error,
          ),
        ],
      ),
    );
  }
}
