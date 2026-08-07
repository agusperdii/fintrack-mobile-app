// app_grid_background.dart
// Widget atom yang menyediakan latar belakang bermotif grid (garis kotak-
// kotak) dengan gradient fade, digunakan sebagai dekorasi layar.

import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';

class AppGridBackground extends StatelessWidget {
  final Widget child;

  const AppGridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _BoxGridPainter(
              color: SavaioTheme.primaryOf(context).withValues(alpha: 0.08),
              spacing: 32.0,
            ),
          ),
        ),
        // Gradient overlay agar grid memudar secara halus ke arah bawah
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scaffoldColor.withValues(alpha: 0.0),
                  scaffoldColor.withValues(alpha: 0.6),
                  scaffoldColor,
                ],
                stops: const [0.2, 0.6, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BoxGridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _BoxGridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoxGridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.spacing != spacing;
  }
}
