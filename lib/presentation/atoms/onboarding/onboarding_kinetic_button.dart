import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingKineticButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const OnboardingKineticButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: KineticVaultTheme.primaryGradient,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: KineticVaultTheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: KineticVaultTheme.onPrimaryFixed,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    color: KineticVaultTheme.onPrimaryFixed,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
