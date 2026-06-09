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
      borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconContainer(
              icon: icon,
              size: 72,
              shape: AppIconShape.rounded,
              customRadius: SavaioTheme.radiusXl,
              color: variant == AppIconButtonVariant.normal 
                ? Theme.of(context).colorScheme.surfaceContainerHighest 
                : null,
              gradient: variant == AppIconButtonVariant.gradient 
                ? SavaioTheme.primaryGradient 
                : null,
              iconColor: variant == AppIconButtonVariant.gradient 
                ? SavaioTheme.onPrimaryFixed 
                : (color ?? Theme.of(context).colorScheme.primary),
              opacity: 1.0,
            ),
            const SizedBox(height: 10),
            AppHeading(
              label,
              size: AppHeadingSize.caption,
              color: variant == AppIconButtonVariant.gradient 
                ? Theme.of(context).colorScheme.onSurface 
                : Theme.of(context).colorScheme.onSurfaceVariant,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}
