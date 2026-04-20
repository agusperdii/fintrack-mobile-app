import 'package:flutter/material.dart';
import '../../atoms/onboarding/onboarding_glow.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingHeroContainer extends StatelessWidget {
  final Widget child;
  final List<Widget>? overlays;

  const OnboardingHeroContainer({
    super.key,
    required this.child,
    this.overlays,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Consistent Background Glows
          Positioned(
            top: 100,
            child: OnboardingGlow(
              color: KineticVaultTheme.primary,
              size: 280,
              opacity: 0.15,
              blurRadius: 80,
            ),
          ),
          Positioned(
            top: 50,
            right: -50,
            child: OnboardingGlow(
              color: KineticVaultTheme.secondary,
              size: 200,
              opacity: 0.1,
              blurRadius: 60,
            ),
          ),

          // Main Visual Content
          child,

          // Floating Overlays
          if (overlays != null) ...overlays!,
        ],
      ),
    );
  }
}
