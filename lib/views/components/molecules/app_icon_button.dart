import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

enum AppIconButtonVariant { normal, gradient }

class AppIconButton extends StatelessWidget {
  final dynamic icon;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final primaryGradient = LinearGradient(
      colors: [colorScheme.primary, colorScheme.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
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
                  ? colorScheme.surfaceContainerHighest 
                  : null,
                gradient: variant == AppIconButtonVariant.gradient 
                  ? primaryGradient 
                  : null,
                iconColor: variant == AppIconButtonVariant.gradient 
                  ? colorScheme.onPrimary
                  : (color ?? colorScheme.primary),
                opacity: 1.0,
              ),
              const SizedBox(height: 8),
              AppHeading(
                label,
                size: AppHeadingSize.caption,
                color: variant == AppIconButtonVariant.gradient 
                  ? colorScheme.onSurface 
                  : colorScheme.onSurfaceVariant,
                isBold: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
