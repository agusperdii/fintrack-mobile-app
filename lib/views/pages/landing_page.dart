// landing_page.dart
// Halaman onboarding/landing yang ditampilkan sebelum pengguna login,
// berisi carousel perkenalan fitur aplikasi dan tombol menuju login/register.
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/pages/login_page.dart';
import 'package:savaio/views/pages/register_page.dart';
import 'package:savaio/views/components/atoms/app_grid_background.dart';
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
    title: 'Masih sering lupa catat pengeluaran?',
    description:
        'Pengeluaran kecil yang terlihat sepele sering kali bikin budget berantakan tanpa disadari.',
    image: 'assets/gambar1.png',
  ),
  OnboardingData(
    title: 'Bingung uang habis ke mana?',
    description:
        'Savaio bantu kamu memahami pola spending lewat insight yang relevan dan mudah dipahami.',
    image: 'assets/gambar2.png',
  ),
  OnboardingData(
    title: 'Pengen ambil kendali atas keuanganmu?',
    description:
        'Yuk mulai bersama Savaio dan bangun kebiasaan finansial yang lebih sehat, satu langkah kecil setiap hari.',
    image: 'assets/gambar3.png',
  ),
];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(BuildContext context,
      {Widget? destination}) async {
    final authController = context.read<AuthController>();
    await authController.setHasSeenLanding(true);

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => destination ?? const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AppGridBackground(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SavaioTheme.primaryOf(context).withValues(alpha: 0.15),
                Colors.transparent,
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
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
                      pageController: _pageController,
                      index: index,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SavaioTheme.spacing2xl,
                ),
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
                                : SavaioTheme.outlineVariantOf(context)
                                    .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(
                              SavaioTheme.radiusFull,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: SavaioTheme.spacing3xl),
                    if (_currentPage == _onboardingData.length - 1)
                      Column(
                        children: [
                          AppButton(
                            label: 'Mulai',
                            onTap: () => _completeOnboarding(
                              context,
                              destination: const RegisterPage(),
                            ),
                          ),
                          const SizedBox(height: SavaioTheme.spacingM),
                          AppButton(
                            label: 'Saya Sudah Terdaftar',
                            variant: AppButtonVariant.ghost,
                            onTap: () => _completeOnboarding(
                              context,
                              destination: const LoginPage(),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => _completeOnboarding(
                              context,
                              destination: const LoginPage(),
                            ),
                            child: Text(
                              'Lewati',
                              style: textTheme.labelLarge?.copyWith(
                                color: SavaioTheme.onSurfaceVariantOf(context),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            child: AppButton(
                              label: 'Lanjut',
                              icon: Icons.arrow_forward_rounded,
                              onTap: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeInOutCubic,
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

class OnboardingSlide extends StatefulWidget {
  final OnboardingData data;
  final TextTheme textTheme;
  final PageController pageController;
  final int index;

  const OnboardingSlide({
    super.key,
    required this.data,
    required this.textTheme,
    required this.pageController,
    required this.index,
  });

  @override
  State<OnboardingSlide> createState() => _OnboardingSlideState();
}

class _OnboardingSlideState extends State<OnboardingSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        double page = 0.0;
        if (widget.pageController.hasClients &&
            widget.pageController.position.haveDimensions) {
          page = widget.pageController.page ?? 0.0;
        } else {
          page = widget.index.toDouble();
        }

        double offset = page - widget.index;
        double textOpacity = 1 - (offset.abs() * 1.5).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SavaioTheme.spacing2xl),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: widget.data.image != null
                      ? AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, childImage) {
                            final floatY = math.sin(_floatController.value * math.pi * 2) * 8;
                            
                            return Transform.translate(
                              offset: Offset(
                                -offset * 80, 
                                floatY,       
                              ),
                              child: childImage,
                            );
                          },
                          child: Image.asset(
                            widget.data.image!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              Transform.translate(
                offset: Offset(-offset * 30, 0), 
                child: Opacity(
                  opacity: textOpacity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: SavaioTheme.surfaceOf(context).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.data.title,
                              style: widget.textTheme.headlineMedium?.copyWith(
                                fontSize: 24, 
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: SavaioTheme.spacingM),
                            Text(
                              widget.data.description,
                              style: widget.textTheme.bodyLarge?.copyWith(
                                fontSize: 15, 
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SavaioTheme.spacing2xl),
            ],
          ),
        );
      },
    );
  }
}