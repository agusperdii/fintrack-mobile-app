import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';


class TransactionSuccessPage extends StatelessWidget {
  const TransactionSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavaioTheme.background,
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
                    color: SavaioTheme.tertiary.withValues(alpha: 0.1),
                    border: Border.all(color: SavaioTheme.tertiary.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: SavaioTheme.tertiary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Transaksi Berhasil!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SavaioTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Catatan keuangan kamu sudah diperbarui secara otomatis oleh Savaio.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: SavaioTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SavaioTheme.tertiary,
                      foregroundColor: SavaioTheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: Text(
                      'KEMBALI KE DASHBOARD',
                      style: GoogleFonts.inter(
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
