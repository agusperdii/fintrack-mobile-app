import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';

class ConsistencyCard extends StatelessWidget {
  final VoidCallback onTap;

  const ConsistencyCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD44D), // Warm yellow from image
        borderRadius: BorderRadius.circular(SavaioTheme.radiusXl),
      ),
      child: Column(
        children: [
          Text(
            'Kamu Sangat Konsisten!',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E1E1E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Konsistensimu mengalahkan 90% user dari aplikasi ini!',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
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
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
              ),
              child: Text(
                'Lihat Summary',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD44D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
