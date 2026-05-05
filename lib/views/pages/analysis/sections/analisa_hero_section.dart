import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/views/components/organisms/app_hero_analysis_card.dart';
import 'package:savaio/models/analysis_view_data.dart';

class AnalisaHeroSection extends StatelessWidget {
  final AnalysisViewData data;

  const AnalisaHeroSection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeroAnalysisCard(
      averageAmountText: SavaioTheme.formatCurrency(data.averageAmount),
      budgetPercentage: data.budgetPercentage,
      isBelowBudget: data.isBelowBudget,
      dailyValues: data.dailyTrend.take(7).toList(),
    );
  }
}
