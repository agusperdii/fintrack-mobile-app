import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_progress_bar.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/view_models/analysis_view_model.dart';

class AppCategoryCard extends StatelessWidget {
  final CategoryVM vm;
  final VoidCallback onTap;

  const AppCategoryCard({
    super.key,
    required this.vm,
    required this.onTap,
  });

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return SavaioTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _parseColor(vm.accentColorHex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SavaioTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (vm.icon is String)
                      Text(
                        vm.icon as String,
                        style: const TextStyle(fontSize: 24),
                      )
                    else
                      AppIconContainer(
                        icon: (vm.icon as IconData?) ?? Icons.category,
                        color: accentColor,
                        shape: AppIconShape.rounded,
                        size: 40,
                      ),
                    const SizedBox(width: 12),
                    AppHeading(
                      vm.name,
                      size: AppHeadingSize.subtitle,
                    ),
                  ],
                ),
                AppHeading(
                  vm.amount,
                  size: AppHeadingSize.h3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppProgressBar(value: vm.progress, color: accentColor, height: 4),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppHeading(
                  vm.limitText,
                  size: AppHeadingSize.caption,
                  color: SavaioTheme.onSurfaceVariant,
                  isBold: true,
                ),
                AppHeading(
                  vm.statusText.toUpperCase(),
                  size: AppHeadingSize.caption,
                  color: accentColor,
                  isBold: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
