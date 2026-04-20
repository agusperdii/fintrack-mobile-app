import 'package:flutter/material.dart';

class OnboardingTemplate extends StatelessWidget {
  final Widget hero;
  final Widget header;
  final Widget footer;

  const OnboardingTemplate({
    super.key,
    required this.hero,
    required this.header,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section (Expanding)
              Expanded(
                child: Center(child: hero),
              ),
              
              // Editorial Copy
              header,
              
              const SizedBox(height: 48),
              
              // Navigation Actions
              footer,
            ],
          ),
        ),
      ),
    );
  }
}
