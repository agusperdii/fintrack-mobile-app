import 'package:flutter/material.dart';
import '../../atoms/onboarding/onboarding_kinetic_button.dart';
import '../../atoms/onboarding/onboarding_progress_dot.dart';

class OnboardingFooter extends StatelessWidget {
  final VoidCallback onContinue;
  final int totalSteps;
  final int currentStep;

  const OnboardingFooter({
    super.key,
    required this.onContinue,
    this.totalSteps = 3,
    this.currentStep = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            totalSteps,
            (index) => OnboardingProgressDot(isActive: index == currentStep),
          ),
        ),
        const SizedBox(height: 32),
        OnboardingKineticButton(
          label: 'Lanjutkan',
          onTap: onContinue,
          icon: Icons.east_rounded,
        ),
      ],
    );
  }
}
