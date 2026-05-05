import 'package:flutter/material.dart';

class NudgeBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const NudgeBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Semantics(
      label: 'Badge: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.2),
          borderRadius: const BorderRadius.all(Radius.circular(9999)),
          border: Border.all(
            color: effectiveColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: effectiveColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
