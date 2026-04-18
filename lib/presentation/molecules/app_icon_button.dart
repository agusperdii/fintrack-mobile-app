import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/app_icon_container.dart';
import '../atoms/app_heading.dart';

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
                ? KineticVaultTheme.surfaceContainerHighest 
                : null,
              gradient: variant == AppIconButtonVariant.gradient 
                ? KineticVaultTheme.primaryGradient 
                : null,
              iconColor: variant == AppIconButtonVariant.gradient 
                ? KineticVaultTheme.onPrimaryFixed 
                : (color ?? KineticVaultTheme.primary),
              opacity: 1.0,
            ),
            const SizedBox(height: 8),
            AppHeading(
              label,
              size: AppHeadingSize.caption,
              color: variant == AppIconButtonVariant.gradient 
                ? KineticVaultTheme.onSurface 
                : KineticVaultTheme.onSurfaceVariant,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}
