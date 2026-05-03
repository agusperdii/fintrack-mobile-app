import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/organisms/app_header.dart';

class PlaceholderPage extends StatelessWidget {
  final String featureName;

  const PlaceholderPage({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: AppHeader(
        title: featureName,
        showBackButton: true,
        showNotification: false,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: SavaioTheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      color: SavaioTheme.primary,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Segera Hadir!',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: SavaioTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fitur "$featureName" sedang dalam tahap pengembangan untuk memberikan pengalaman finansial terbaik bagi Anda.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: SavaioTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SavaioTheme.primary,
                      foregroundColor: SavaioTheme.onPrimaryFixed,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: Text(
                      'KEMBALI',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
