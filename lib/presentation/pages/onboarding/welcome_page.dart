import 'package:flutter/material.dart';
import '../../molecules/onboarding/onboarding_editorial_header.dart';
import '../../organisms/onboarding/onboarding_footer.dart';
import '../../organisms/onboarding/onboarding_hero_section.dart';
import '../../organisms/onboarding/onboarding_intelligence_hero.dart';
import '../../organisms/onboarding/onboarding_analysis_hero.dart';
import '../../templates/onboarding/onboarding_template.dart';

class OnboardingData {
  final Widget hero;
  final String title;
  final String emphasizedTitle;
  final String description;

  OnboardingData({
    required this.hero,
    required this.title,
    required this.emphasizedTitle,
    required this.description,
  });
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  late final List<OnboardingData> _pages = [
    OnboardingData(
      hero: const OnboardingHeroSection(),
      title: 'Catat Pengeluaran',
      emphasizedTitle: 'Secepat Kilat.',
      description: 'Didesain khusus untuk mahasiswa yang sibuk. Lupakan input manual yang membosankan.',
    ),
    OnboardingData(
      hero: const OnboardingIntelligenceHero(),
      title: 'Nudge Pintar yang',
      emphasizedTitle: 'Mengerti Kamu.',
      description: 'Dapatkan pengingat cerdas agar budget bulanan tetap aman tanpa rasa terbebani.',
    ),
    OnboardingData(
      hero: const OnboardingAnalysisHero(),
      title: 'Analisa Cerdas',
      emphasizedTitle: 'Untukmu.',
      description: 'Pantau setiap pengeluaran secara otomatis dengan wawasan cerdas yang membantu finansialmu tumbuh lebih sehat.',
    ),
  ];

  void _onNext() {
    if (_currentStep < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentStep = index),
        itemBuilder: (context, index) {
          final data = _pages[index];
          return OnboardingTemplate(
            hero: data.hero,
            header: OnboardingEditorialHeader(
              title: data.title,
              emphasizedTitle: data.emphasizedTitle,
              description: data.description,
            ),
            footer: OnboardingFooter(
              onContinue: _onNext,
              currentStep: _currentStep,
              totalSteps: _pages.length,
            ),
          );
        },
      ),
    );
  }
}
