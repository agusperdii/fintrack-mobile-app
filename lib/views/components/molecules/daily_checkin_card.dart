import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class DailyCheckInCard extends StatelessWidget {
  const DailyCheckInCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        final status = provider.checkInStatus;

        if (status == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SavaioTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: SavaioTheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SavaioTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: SavaioTheme.primary,
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
                      status.isCheckedInToday 
                          ? 'Streak ${status.streakCount} hari! Sampai jumpa besok.'
                          : 'Ayo check-in hari ini untuk jaga streak kamu!',
                      style: const TextStyle(
                        color: SavaioTheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!status.isCheckedInToday)
                AppButton(
                  onTap: () => provider.performCheckIn(),
                  label: 'Check-in',
                  small: true,
                  width: 90,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SavaioTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: SavaioTheme.success),
                      SizedBox(width: 4),
                      Text(
                        'Done',
                        style: TextStyle(
                          color: SavaioTheme.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
