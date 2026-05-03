import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

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
          color: SavaioTheme.surfaceContainerLow,
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
                  color: isOverBudget ? SavaioTheme.error : SavaioTheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppProgressBar(
              value: progress,
              color: isOverBudget ? SavaioTheme.error : SavaioTheme.primary,
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
