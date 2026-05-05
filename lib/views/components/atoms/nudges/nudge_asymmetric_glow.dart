import 'package:flutter/material.dart';

class NudgeAsymmetricGlow extends StatelessWidget {
  final Color? color;
  final double size;
  final double blurRadius;
  final double spreadRadius;
  final double opacity;

  const NudgeAsymmetricGlow({
    super.key,
    this.color,
    this.size = 256,
    this.blurRadius = 80,
    this.spreadRadius = 20,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: opacity),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
    );
  }
}
