import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AppSmartInsightCard extends StatelessWidget {
  final AnalysisInsight vm;
  final VoidCallback onTap;

  const AppSmartInsightCard({
    super.key,
    required this.vm,
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
            vm.title,
            size: AppHeadingSize.h3,
          ),
          const SizedBox(height: 12),
          AppHeading(
            vm.description,
            size: AppHeadingSize.subtitle,
            color: SavaioTheme.onSurfaceVariant,
            isBold: false,
          ),
          const SizedBox(height: 24),
          if (vm.buttonLabel != null)
            AppButton(
              label: vm.buttonLabel!,
              onTap: onTap,
              icon: Icons.arrow_forward,
            ),
        ],
      ),
    );
  }
}
