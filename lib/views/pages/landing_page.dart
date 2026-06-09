import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/pages/login_page.dart';
import 'package:savaio/views/pages/register_page.dart';
import 'package:savaio/controllers/auth_controller.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Welcome to Savaio',
      description: 'Elegant finance tracking for the modern era. Take control of your money with style.',
      image: 'assets/savaio-logo-tinted.png',
    ),
    OnboardingData(
      title: 'Smart Insights',
      description: 'Get AI-powered analytics to understand your spending patterns and save more efficiently.',
      icon: Icons.auto_awesome_rounded,
    ),
    OnboardingData(
      title: 'Secure & Private',
      description: 'Your financial data is encrypted and secure. We prioritize your privacy above all else.',
      icon: Icons.security_rounded,
    ),
  ];

  Future<void> _completeOnboarding(BuildContext context, {Widget? destination}) async {
    final authController = context.read<AuthController>();
    await authController.setHasSeenLanding(true);
    
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination ?? const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingSlide(
                    data: _onboardingData[index],
                    textTheme: textTheme,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SavaioTheme.spacing2xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: SavaioTheme.durationNormal,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? SavaioTheme.primaryOf(context)
                              : SavaioTheme.outlineVariantOf(context),
                          borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SavaioTheme.spacing3xl),
                  if (_currentPage == _onboardingData.length - 1)
                    Column(
                      children: [
                        AppButton(
                          label: 'Get Started',
                          onTap: () => _completeOnboarding(context, destination: const RegisterPage()),
                        ),
                        const SizedBox(height: SavaioTheme.spacingM),
                        AppButton(
                          label: 'I already registered',
                          variant: AppButtonVariant.ghost,
                          onTap: () => _completeOnboarding(context, destination: const LoginPage()),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _completeOnboarding(context, destination: const LoginPage()),
                          child: Text(
                            'SKIP',
                            style: textTheme.labelLarge?.copyWith(
                              color: SavaioTheme.onSurfaceVariantOf(context),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: AppButton(
                            label: 'NEXT',
                            icon: Icons.arrow_forward_rounded,
                            onTap: () {
                              _pageController.nextPage(
                                duration: SavaioTheme.durationNormal,
                                curve: SavaioTheme.curveDefault,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: SavaioTheme.spacing2xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String? image;
  final IconData? icon;

  OnboardingData({
    required this.title,
    required this.description,
    this.image,
    this.icon,
  });
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingData data;
  final TextTheme textTheme;

  const OnboardingSlide({
    super.key,
    required this.data,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SavaioTheme.spacing2xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (data.image != null)
            Image.asset(
              data.image!,
              height: 200,
              fit: BoxFit.contain,
            )
          else if (data.icon != null)
            Container(
              padding: const EdgeInsets.all(SavaioTheme.spacing3xl),
              decoration: BoxDecoration(
                color: SavaioTheme.primaryOf(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: SavaioTheme.primaryOf(context).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                data.icon,
                size: 80,
                color: SavaioTheme.primaryOf(context),
              ),
            ),
          const SizedBox(height: SavaioTheme.spacing4xl),
          Text(
            data.title,
            style: textTheme.headlineMedium?.copyWith(
              color: SavaioTheme.onSurfaceOf(context),
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SavaioTheme.spacingL),
          Text(
            data.description,
            style: textTheme.bodyLarge?.copyWith(
              color: SavaioTheme.onSurfaceVariantOf(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
