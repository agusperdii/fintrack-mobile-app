import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppSmartInsightCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const AppSmartInsightCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeading(
            title,
            size: AppHeadingSize.h3,
          ),
          const SizedBox(height: 12),
          AppHeading(
            description,
            size: AppHeadingSize.subtitle,
            color: SavaioTheme.onSurfaceVariant,
            isBold: false,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: buttonLabel,
            onTap: onTap,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}
