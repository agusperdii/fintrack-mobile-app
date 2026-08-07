// app_greeting_header.dart
// Widget molecule header sapaan pengguna beserta badge status anggaran
// (aman, hati-hati, atau over budget) di halaman dashboard.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppGreetingHeader extends StatelessWidget {
  final String userName;
  /// Nilai valid: 'active' (Aman), 'warning' (Hati-hati), 'exceeded' (Over Budget).
  final String budgetStatus;

  const AppGreetingHeader({
    super.key, 
    required this.userName,
    this.budgetStatus = 'active',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeading('Hi, $userName!', size: AppHeadingSize.h2),
        const SizedBox(height: 4),
        _buildStatusBadge(context),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    String label;

    switch (budgetStatus) {
      case 'exceeded':
        color = SavaioTheme.errorOf(context);
        label = 'Over Budget';
        break;
      case 'warning':
        color = SavaioTheme.warningOf(context);
        label = 'HATI-HATI';
        break;
      default:
        color = SavaioTheme.tertiaryOf(context);
        label = 'AMAN';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
