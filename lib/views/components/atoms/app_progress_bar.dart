import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: SavaioTheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? SavaioTheme.primary),
      ),
    );
  }
}
