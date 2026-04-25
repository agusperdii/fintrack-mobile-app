import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../atoms/glass_card.dart';
import '../atoms/app_heading.dart';
import '../molecules/app_segment_toggle_button.dart';

class AppTrendLineChart extends StatelessWidget {
  final String title;
  final List<String> days;
  final int activeDayIndex;
  final VoidCallback onToggle;

  const AppTrendLineChart({
    super.key,
    required this.title,
    this.days = const ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'],
    this.activeDayIndex = 3,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppHeading(title, size: AppHeadingSize.h3),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: KineticVaultTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    AppSegmentToggleButton(label: 'Minggu Ini', isActive: true, onTap: onToggle),
                    AppSegmentToggleButton(label: 'Bulan Ini', isActive: false, onTap: onToggle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendLinePainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              final isToday = entry.key == activeDayIndex;
              return AppHeading(
                entry.value,
                size: AppHeadingSize.caption,
                color: isToday ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [KineticVaultTheme.primary, KineticVaultTheme.secondary],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.8, size.width * 0.3, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.45, size.height * 0.5, size.width * 0.6, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.6, size.width * 0.9, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.5);

    final shadowPaint = Paint()
      ..color = KineticVaultTheme.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    final pointPaint = Paint()
      ..color = KineticVaultTheme.primary
      ..style = PaintingStyle.fill;
    
    final glowPaint = Paint()
      ..color = KineticVaultTheme.primary.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final activeX = size.width * 0.6;
    const activeY = 30.0; 
    canvas.drawCircle(Offset(activeX, activeY), 8, glowPaint);
    canvas.drawCircle(Offset(activeX, activeY), 4, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
