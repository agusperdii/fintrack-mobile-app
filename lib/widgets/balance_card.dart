import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/kinetic_vault_theme.dart';
import 'glass_card.dart';
import 'ambient_glow.dart';

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24.0),
        borderRadius: 16,
        color: const Color(0x9923262C),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Realistic Soft Glow at Top Right
            const Positioned(
              right: -140,
              top: -140,
              child: AmbientGlow(
                size: 280,
                color: KineticVaultTheme.primary,
                opacity: 0.1,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SISA UANG ANDA',
                  style: GoogleFonts.plusJakartaSans(
                    color: KineticVaultTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rp ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                  style: GoogleFonts.plusJakartaSans(
                    color: KineticVaultTheme.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KineticVaultTheme.errorDim.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: KineticVaultTheme.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anda hampir mencapai batas pengeluaran hari ini!',
                          style: GoogleFonts.inter(
                            color: KineticVaultTheme.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
