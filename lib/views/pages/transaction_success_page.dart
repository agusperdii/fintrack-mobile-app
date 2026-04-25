import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';


class TransactionSuccessPage extends StatelessWidget {
  const TransactionSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      body: Stack(
        children: [

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KineticVaultTheme.tertiary.withValues(alpha: 0.1),
                    border: Border.all(color: KineticVaultTheme.tertiary.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: KineticVaultTheme.tertiary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Transaksi Berhasil!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: KineticVaultTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Catatan keuangan kamu sudah diperbarui secara otomatis oleh Kinetic Vault.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: KineticVaultTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KineticVaultTheme.tertiary,
                      foregroundColor: KineticVaultTheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: Text(
                      'KEMBALI KE DASHBOARD',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
