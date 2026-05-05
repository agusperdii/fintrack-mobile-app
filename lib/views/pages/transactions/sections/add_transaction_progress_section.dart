import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/atoms/glass_card.dart';

class AddTransactionProgressSection extends StatelessWidget {
  final double progress;
  final String label;
  final String description;

  const AddTransactionProgressSection({
    super.key,
    required this.progress,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeading(
                    label,
                    size: AppHeadingSize.subtitle,
                    color: colorScheme.tertiary,
                    isBold: true,
                  ),
                  AppHeading(
                    description,
                    size: AppHeadingSize.caption,
                    color: colorScheme.onSurfaceVariant,
                    isBold: false,
                  ),
                ],
              ),
              AppHeading(
                '${(progress * 100).toInt()}%',
                size: AppHeadingSize.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppProgressBar(
            value: progress,
            color: colorScheme.tertiary,
            height: 6,
          ),
        ],
      ),
    );
  }
}
