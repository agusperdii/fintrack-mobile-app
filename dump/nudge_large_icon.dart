import 'package:flutter/material.dart';

class NudgeLargeIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String? semanticLabel;

  const NudgeLargeIcon({
    super.key, 
    required this.icon, 
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Semantics(
      label: semanticLabel ?? 'Icon',
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: effectiveColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: effectiveColor.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 48,
          color: effectiveColor,
        ),
      ),
    );
  }
}
