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
        borderRadius: BorderRadius.circular(KineticVaultTheme.radiusFull),
        boxShadow: [
          BoxShadow(
            color: KineticVaultTheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(KineticVaultTheme.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KineticVaultTheme.spacingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: KineticVaultTheme.onPrimaryFixed,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1.1,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: KineticVaultTheme.spacingS),
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
