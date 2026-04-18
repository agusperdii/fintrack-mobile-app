import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/app_progress_bar.dart';
import '../atoms/app_heading.dart';

class AppWeeklySummaryItem extends StatelessWidget {
  final String title;
  final String amount;
  final double progress;
  final VoidCallback onTap;

  const AppWeeklySummaryItem({
    super.key,
    required this.title,
    required this.amount,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverBudget = progress > 1.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KineticVaultTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppHeading(
                  title,
                  size: AppHeadingSize.subtitle,
                ),
                AppHeading(
                  amount,
                  size: AppHeadingSize.subtitle,
                  color: isOverBudget ? KineticVaultTheme.error : KineticVaultTheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppProgressBar(
              value: progress,
              color: isOverBudget ? KineticVaultTheme.error : KineticVaultTheme.primary,
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
