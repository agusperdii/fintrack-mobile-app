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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SavaioTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppHeading(
                    title,
                    size: AppHeadingSize.subtitle,
                    isBold: true,
                  ),
                ),
                AppHeading(
                  amount,
                  size: AppHeadingSize.subtitle,
                  color: SavaioTheme.onSurface,
                  isBold: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppProgressBar(
              value: progress,
              color: SavaioTheme.primary,
              height: 6,
            ),
          ],
        ),
      ),
    );
  }
}
