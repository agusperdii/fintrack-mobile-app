import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;
  final double height;
  final String? semanticLabel;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clampedValue = value.clamp(0.0, 1.0);

    return Semantics(
      label: semanticLabel ?? 'Progress Bar',
      value: '${(clampedValue * 100).toInt()}%',
      maxValue: '100%',
      minValue: '0%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: clampedValue,
          minHeight: height,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? colorScheme.primary),
        ),
      ),
    );
  }
}
