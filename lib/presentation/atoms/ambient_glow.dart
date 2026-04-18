import 'package:flutter/material.dart';

class AmbientGlow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const AmbientGlow({
    super.key,
    this.size = 400,
    required this.color,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.5),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}
