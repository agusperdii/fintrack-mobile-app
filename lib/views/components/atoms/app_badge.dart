// app_badge.dart
// Widget atom badge/label kecil dengan beberapa varian warna (success,
// error, warning, neutral) untuk menampilkan status singkat.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';

enum AppBadgeVariant { success, error, warning, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppBadgeVariant.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    switch (variant) {
      case AppBadgeVariant.success: color = colorScheme.tertiary; break;
      case AppBadgeVariant.error: color = colorScheme.error; break;
      case AppBadgeVariant.warning: color = Colors.orange; break;
      case AppBadgeVariant.neutral: color = colorScheme.onSurfaceVariant; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusS),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 10),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
