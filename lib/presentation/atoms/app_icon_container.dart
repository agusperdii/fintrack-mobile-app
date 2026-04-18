import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AppIconShape { circle, rounded }

class AppIconContainer extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Gradient? gradient;
  final double size;
  final AppIconShape shape;
  final double opacity;
  final Color? iconColor;

  const AppIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.gradient,
    this.size = 40,
    this.shape = AppIconShape.circle,
    this.opacity = 0.1,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? KineticVaultTheme.primary).withValues(alpha: opacity) : null,
        gradient: gradient,
        shape: shape == AppIconShape.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape == AppIconShape.rounded ? BorderRadius.circular(12) : null,
        boxShadow: gradient != null ? [
          BoxShadow(
            color: (iconColor ?? Colors.white).withValues(alpha: 0.3),
            blurRadius: 15,
          ),
        ] : null,
      ),
      child: Icon(
        icon, 
        color: iconColor ?? color ?? KineticVaultTheme.primary, 
        size: size * 0.5
      ),
    );
  }
}
