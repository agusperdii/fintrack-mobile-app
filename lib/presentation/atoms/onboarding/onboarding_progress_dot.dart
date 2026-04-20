import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingProgressDot extends StatelessWidget {
  final bool isActive;
  final double width;

  const OnboardingProgressDot({
    super.key,
    this.isActive = false,
    this.width = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : width,
      decoration: BoxDecoration(
        gradient: isActive ? KineticVaultTheme.primaryGradient : null,
        color: isActive ? null : KineticVaultTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
