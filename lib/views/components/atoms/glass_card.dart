import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
    this.blur = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final effectiveBorderColor = borderColor ?? colorScheme.outlineVariant.withValues(alpha: 0.1);
    final effectiveColor = color ?? colorScheme.surfaceContainer.withValues(alpha: 0.6);

    return Semantics(
      container: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
