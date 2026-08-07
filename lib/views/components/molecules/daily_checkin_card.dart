// daily_checkin_card.dart
// Widget molecule kartu ajakan check-in harian untuk menjaga streak
// pengguna, hanya tampil jika pengguna belum check-in hari ini.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class DailyCheckInCard extends StatelessWidget {
  const DailyCheckInCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final status = controller.checkInStatus;

    if (status == null || status.isCheckedInToday) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLowOf(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: SavaioTheme.primaryOf(context).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: SavaioTheme.primaryOf(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: SavaioTheme.primaryOf(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeading(
                  'Daily Check-in',
                  size: AppHeadingSize.subtitle,
                ),
                const SizedBox(height: 2),
                Text(
                  'Ayo check-in hari ini untuk jaga streak kamu!',
                  style: TextStyle(
                    color: SavaioTheme.onSurfaceVariantOf(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppButton(
            onTap: () async {
              final status = await controller.checkIn();
              if (status.isCheckedInToday) {
                sl.notificationController.fetchAll();
              }
            },
            label: 'Check-in',
            small: true,
            width: 90,
          ),
        ],
      ),
    );
  }
}
