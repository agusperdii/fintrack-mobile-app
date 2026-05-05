import 'package:flutter/material.dart';
import 'package:savaio/others.dart';

enum AppIconShape { circle, rounded }

class AppIconContainer extends StatelessWidget {
  final dynamic icon; // Can be IconData or String (emoji)
  final Color? color;
  final Gradient? gradient;
  final double size;
  final AppIconShape shape;
  final double opacity;
  final Color? iconColor;
  final String? semanticLabel;

  const AppIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.gradient,
    this.size = 40,
    this.shape = AppIconShape.circle,
    this.opacity = 0.1,
    this.iconColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final effectiveColor = color ?? colorScheme.primary;

    return Semantics(
      label: semanticLabel ?? (icon is String ? icon as String : 'Icon Container'),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gradient == null ? effectiveColor.withValues(alpha: opacity) : null,
          gradient: gradient,
          shape: shape == AppIconShape.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: shape == AppIconShape.rounded 
            ? BorderRadius.circular(SavaioTheme.radiusM) 
            : null,
        ),
        child: _buildIcon(effectiveColor),
      ),
    );
  }

  Widget _buildIcon(Color effectiveColor) {
    if (icon is IconData) {
      return Icon(
        icon as IconData,
        color: iconColor ?? effectiveColor,
        size: size * 0.5,
      );
    } else if (icon is String) {
      return Text(
        icon as String,
        style: TextStyle(fontSize: size * 0.5),
      );
    }
    return const SizedBox.shrink();
  }
}
