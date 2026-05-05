import 'package:flutter/material.dart';

enum AppBadgeVariant { success, error, warning, neutral, primary }

class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AppBadgeVariant variant;
  final Color? color;
  final TextStyle? style;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppBadgeVariant.neutral,
    this.color,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color effectiveColor;
    switch (variant) {
      case AppBadgeVariant.success:
        effectiveColor = colorScheme.tertiary;
        break;
      case AppBadgeVariant.error:
        effectiveColor = colorScheme.error;
        break;
      case AppBadgeVariant.warning:
        effectiveColor = Colors.orange; // fallback or custom if not in colorScheme
        break;
      case AppBadgeVariant.primary:
        effectiveColor = colorScheme.primary;
        break;
      case AppBadgeVariant.neutral:
        effectiveColor = colorScheme.onSurfaceVariant;
        break;
    }

    if (color != null) effectiveColor = color!;

    return Semantics(
      label: 'Badge: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: effectiveColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: effectiveColor, size: 12),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: effectiveColor,
                  letterSpacing: 0.5,
                ).merge(style),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
