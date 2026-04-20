import 'package:flutter/material.dart';

class OnboardingGlow extends StatelessWidget {
  final Color color;
  final double size;
  final double blurRadius;
  final double opacity;

  const OnboardingGlow({
    super.key,
    required this.color,
    this.size = 300,
    this.blurRadius = 100,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: blurRadius,
            spreadRadius: blurRadius / 2,
          ),
        ],
      ),
    );
  }
}
