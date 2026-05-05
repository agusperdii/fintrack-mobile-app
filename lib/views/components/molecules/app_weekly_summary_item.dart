import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppWeeklySummaryItem extends StatelessWidget {
  final String title;
  final String amount;
  final double progress;
  final VoidCallback onTap;
  final Color? amountColor;
  final Color? progressBarColor;

  const AppWeeklySummaryItem({
    super.key,
    required this.title,
    required this.amount,
    required this.progress,
    required this.onTap,
    this.amountColor,
    this.progressBarColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverBudget = progress > 1.0;
    
    final effectiveAmountColor = amountColor ?? (isOverBudget ? colorScheme.error : colorScheme.onSurface);
    final effectiveBarColor = progressBarColor ?? (isOverBudget ? colorScheme.error : colorScheme.primary);

    return Semantics(
      button: true,
      label: 'Weekly summary for $title: $amount',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppHeading(
                      title,
                      size: AppHeadingSize.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppHeading(
                    amount,
                    size: AppHeadingSize.subtitle,
                    color: effectiveAmountColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppProgressBar(
                value: progress,
                color: effectiveBarColor,
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
