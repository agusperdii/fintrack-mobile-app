import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/views/pages/spending_target_page.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_icon_container.dart';

class NudgeOverlay extends StatelessWidget {
  final NudgeData nudge;
  final VoidCallback onDismiss;

  const NudgeOverlay({
    super.key,
    required this.nudge,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = nudge.type == NudgeType.positive;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SavaioTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          AppIconContainer(
            icon: nudge.icon,
            color: isPositive ? SavaioTheme.tertiary : SavaioTheme.primary,
            size: 80,
            opacity: 0.15,
          ),
          const SizedBox(height: 24),
          AppHeading(
            isPositive ? 'Selamat!' : 'Perhatian',
            size: AppHeadingSize.h2,
            color: isPositive ? SavaioTheme.tertiary : SavaioTheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            nudge.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: SavaioTheme.onSurface,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          AppButton(
            label: isPositive ? 'TERIMA KASIH' : 'SAYA MENGERTI',
            onTap: onDismiss,
          ),
          if (!isPositive && nudge.type == NudgeType.warning) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                onDismiss();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SpendingTargetPage(initialCategory: nudge.targetCategory)),
                );
              },
              child: const Text(
                'LIHAT BUDGET KATEGORI',
                style: TextStyle(color: SavaioTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void show(BuildContext context, NudgeData nudge, VoidCallback onRead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NudgeOverlay(
        nudge: nudge,
        onDismiss: () {
          onRead();
          Navigator.pop(context);
        },
      ),
    );
  }
}
