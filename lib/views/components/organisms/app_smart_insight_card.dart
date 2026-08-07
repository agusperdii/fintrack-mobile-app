// app_smart_insight_card.dart
// Kartu insight otomatis yang menampilkan judul dan deskripsi wawasan
// keuangan dengan warna dan ikon yang menyesuaikan tingkat severity.

import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AppSmartInsightCard extends StatelessWidget {
  final AnalysisInsight vm;

  const AppSmartInsightCard({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor;
    IconData icon;

    switch (vm.severity) {
      case 'danger':
        accentColor = isDark ? SavaioTheme.error : SavaioTheme.lightError;
        icon = Icons.error_outline_rounded;
        break;
      case 'warning':
        accentColor = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case 'info':
      default:
        accentColor = Theme.of(context).colorScheme.primary;
        icon = Icons.lightbulb_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: AppHeading(
                  vm.title,
                  size: AppHeadingSize.h3,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppHeading(
            vm.description,
            size: AppHeadingSize.subtitle,
            color: SavaioTheme.onSurfaceVariantOf(context),
            isBold: false,
          ),
        ],
      ),
    );
  }
}
