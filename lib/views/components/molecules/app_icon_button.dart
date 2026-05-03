import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

enum AppIconButtonVariant { normal, gradient }

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final AppIconButtonVariant variant;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.variant = AppIconButtonVariant.normal,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconContainer(
              icon: icon,
              size: 56,
              color: variant == AppIconButtonVariant.normal 
                ? SavaioTheme.surfaceContainerHighest 
                : null,
              gradient: variant == AppIconButtonVariant.gradient 
                ? SavaioTheme.primaryGradient 
                : null,
              iconColor: variant == AppIconButtonVariant.gradient 
                ? SavaioTheme.onPrimaryFixed 
                : (color ?? SavaioTheme.primary),
              opacity: 1.0,
            ),
            const SizedBox(height: 8),
            AppHeading(
              label,
              size: AppHeadingSize.caption,
              color: variant == AppIconButtonVariant.gradient 
                ? SavaioTheme.onSurface 
                : SavaioTheme.onSurfaceVariant,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}
