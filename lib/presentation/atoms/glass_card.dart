import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.borderColor = const Color(0x1AFFFFFF),
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? const Color(0x9923262C),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
