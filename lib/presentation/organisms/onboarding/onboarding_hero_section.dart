import 'package:flutter/material.dart';
import '../../molecules/onboarding/onboarding_mockup_card.dart';
import 'onboarding_hero_container.dart';

class OnboardingHeroSection extends StatelessWidget {
  const OnboardingHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingHeroContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: OnboardingMockupCard(),
      ),
    );
  }
}
