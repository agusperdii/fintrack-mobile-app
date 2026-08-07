// consistency_card.dart
// Widget molecule kartu ajakan (CTA) yang menampilkan apresiasi atas
// konsistensi pengguna dalam mencatat keuangan.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';

class ConsistencyCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String description;

  final String ctaText;

  const ConsistencyCard({
    super.key,
    required this.onTap,
    this.title = 'Kamu Sangat Konsisten!',
    this.description = 'Konsistensimu mengalahkan 90% user dari aplikasi ini!',
    this.ctaText = 'Lihat Summary',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SavaioTheme.secondaryOf(context),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: SavaioTheme.onPrimaryFixedOf(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SavaioTheme.onPrimaryFixedOf(context).withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: SavaioTheme.onPrimaryFixedOf(context),
                borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
              ),
              child: Text(
                ctaText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: SavaioTheme.secondaryOf(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
