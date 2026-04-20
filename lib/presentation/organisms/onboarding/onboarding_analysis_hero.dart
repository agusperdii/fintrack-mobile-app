import 'package:flutter/material.dart';
import '../../molecules/onboarding/onboarding_mock_transaction_item.dart';
import '../../../core/theme/app_theme.dart';
import 'onboarding_hero_container.dart';

class OnboardingAnalysisHero extends StatelessWidget {
  const OnboardingAnalysisHero({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingHeroContainer(
      overlays: [
        // Floating Decorative Insight (Star)
        Positioned(
          top: 40,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: KineticVaultTheme.tertiary, size: 16),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 8,
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.tertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Central Imagery (Abstract Background)
          Opacity(
            opacity: 0.3,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDfaaYtsCbbRUZLJR9vEntfHBur8phe1SoO0KICi1fcWT5knu_Ybl2tX8zZ2WAbueYDjRmMZZEyCL3gS-sCL28ugyYSDU-L97InMRnpjndvq7FIROYHFq2qnT3OS3dBxlfI0O2NCfwWPzzBO2vVEvm_CKFopgns4REHgJbbHR1Zy0oix31O5SDoHWkXK5tHwe2B0DBFobniMKD-LQcFG42JPCQEUUy8S5OXGSzv9lXldzUZwAMCeA5vh-LsAOmICX5QWdeSCC_fmOI'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Background Glass Card (Rotated)
          Positioned(
            left: 20,
            top: 20,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 240,
                height: 300,
                decoration: BoxDecoration(
                  color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),

          // Foreground Glass Card (Main Content)
          Transform.rotate(
            angle: 0.07,
            child: Container(
              width: 260,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sparkline Mockup
                  Container(
                    width: double.infinity,
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: KineticVaultTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  KineticVaultTheme.tertiary.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(double.infinity, 80),
                          painter: SparklinePainter(color: KineticVaultTheme.tertiary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mock Transaction List
                  const OnboardingMockTransactionItem(
                    icon: Icons.insights_rounded,
                    iconColor: KineticVaultTheme.secondary,
                    iconBgColor: Color(0x33BC87FE),
                    barWidth: 96,
                  ),
                  const SizedBox(height: 12),
                  const OnboardingMockTransactionItem(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: KineticVaultTheme.primary,
                    iconBgColor: Color(0x3381ECFF),
                    barWidth: 128,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final Color color;

  SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(
        size.width * 0.2, size.height * 0.2,
        size.width * 0.4, size.height * 0.6,
        size.width * 0.6, size.height * 0.1,
      )
      ..cubicTo(
        size.width * 0.8, size.height * 0.0,
        size.width * 0.9, size.height * 0.4,
        size.width, size.height * 0.5,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
