import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum AppIconShape { circle, rounded }

class AppIconContainer extends StatelessWidget {
  final dynamic icon; // Can be IconData or String (emoji)
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? SavaioTheme.primary).withValues(alpha: opacity) : null,
        gradient: gradient,
        shape: shape == AppIconShape.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape == AppIconShape.rounded ? BorderRadius.circular(SavaioTheme.radiusM) : null,
      ),
      child: _buildIcon(),
    );
  }

  Widget _buildIcon() {
    if (icon is IconData) {
      return Icon(
        icon as IconData,
        color: iconColor ?? color ?? SavaioTheme.primary,
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
