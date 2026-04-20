import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingEditorialHeader extends StatelessWidget {
  final String title;
  final String emphasizedTitle;
  final String description;

  const OnboardingEditorialHeader({
    super.key,
    required this.title,
    required this.emphasizedTitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: KineticVaultTheme.onSurface,
              letterSpacing: -1,
            ),
            children: [
              TextSpan(text: title),
              const TextSpan(text: ' '),
              TextSpan(
                text: emphasizedTitle,
                style: const TextStyle(
                  color: KineticVaultTheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 18,
            height: 1.6,
            color: KineticVaultTheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
