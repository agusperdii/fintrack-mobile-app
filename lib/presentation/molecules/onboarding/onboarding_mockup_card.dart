import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingMockupCard extends StatelessWidget {
  const OnboardingMockupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom Decorative Card
        Transform.rotate(
          angle: -0.2,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: KineticVaultTheme.surfaceContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // Main Visual Card
        Transform.rotate(
          angle: 0.035,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: KineticVaultTheme.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: KineticVaultTheme.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Express Entry',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: KineticVaultTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: KineticVaultTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: GoogleFonts.plusJakartaSans(
                          color: KineticVaultTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOMINAL',
                      style: GoogleFonts.plusJakartaSans(
                        color: KineticVaultTheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp 25.000',
                      style: GoogleFonts.plusJakartaSans(
                        color: KineticVaultTheme.primary,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDHvFK9PXYUUFg1Zst-SQJmS-RfUlfvoXVTajWyv-AZ1h3Pw9SwyxPNswSggi2FbedzIzK9fauFpQXXTGNIf-ePB0hFkxRSplZbknRXAtfQYH83ANIlE8ycy_j0Gw9rJtWmsB5QuF8kSjOub7wBRTNsaDDDgWjErr2GWOk6CXr-SysWalYtCpBk5FB4KtG8btOCV6X-e-IaMERnx_oHRh1FFFgkZK1SmusjE6pa4limBikl9QnbxnHe_TovIm45Ivdkrr1Kb2dDclE'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Es Kopi Susu',
                              style: GoogleFonts.plusJakartaSans(
                                color: KineticVaultTheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Kantin Pusat',
                              style: GoogleFonts.inter(
                                color: KineticVaultTheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: KineticVaultTheme.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'MAKANAN',
                          style: GoogleFonts.plusJakartaSans(
                            color: KineticVaultTheme.tertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: KineticVaultTheme.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: KineticVaultTheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: KineticVaultTheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Top Floating Tag
        Positioned(
          top: -40,
          right: -8,
          child: Transform.rotate(
            angle: 0.14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: KineticVaultTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: KineticVaultTheme.tertiary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Saved in 0.8s',
                    style: GoogleFonts.plusJakartaSans(
                      color: KineticVaultTheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
