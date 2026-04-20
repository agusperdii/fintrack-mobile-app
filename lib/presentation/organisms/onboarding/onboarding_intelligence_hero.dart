import 'package:flutter/material.dart';
import '../../molecules/onboarding/onboarding_notification.dart';
import '../../../core/theme/app_theme.dart';
import 'onboarding_hero_container.dart';

class OnboardingIntelligenceHero extends StatelessWidget {
  const OnboardingIntelligenceHero({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingHeroContainer(
      overlays: const [
        Positioned(
          top: 20,
          right: -10,
          width: 240,
          child: OnboardingNotification(
            icon: Icons.warning_rounded,
            iconColor: KineticVaultTheme.error,
            iconBgColor: Color(0x339F0519),
            title: 'Budget alert',
            description: "Maybe skip that second coffee? ☕️ You've used 85% of your 'Cafe' budget.",
          ),
        ),
        Positioned(
          bottom: 40,
          left: -10,
          width: 220,
          child: OnboardingNotification(
            icon: Icons.eco_rounded,
            iconColor: KineticVaultTheme.tertiary,
            iconBgColor: Color(0x3300FD74),
            title: 'Smart Move!',
            description: 'You saved \$12 today by walking to campus.',
          ),
        ),
      ],
      child: Container(
        width: 280,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuC1zIu6fhgUSQrxBRNESLSpnQN5veSKww_WirtWQxFxaIjFAp6UKopCaOgceCrkbXpVQme00tgrQaVI5M9wQm5gxGnPqSBx-sDSAY1JdYpabfX-wE6K-qHvdRpRaAShqlFIRaO1BSjzRxoSCqoAUit7gX-fT76TPj2lXq3PwNG-Crlga0BjfyYqSxh6wbeKjwWEw9PKfJGQzbG7xehS7GonKfKzdj98ZU8QZjHWcCVdfqKPjFGCblau-HYALxu-J_n8YUcMaPDfCio'),
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
      ),
    );
  }
}
