import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';
import 'package:savaio/views/components/organisms/app_header.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final status = controller.checkInStatus;
    final streakCount = status?.streakCount ?? 0;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: const AppHeader(
        title: 'My Streak',
        showBackButton: true,
        showNotification: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SavaioTheme.spacingXl),
        child: Column(
          children: [
            const SizedBox(height: SavaioTheme.spacingXl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SavaioTheme.spacing2xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SavaioTheme.secondaryOf(context).withValues(alpha: 0.22),
                    SavaioTheme.primaryOf(context).withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(SavaioTheme.radius2xl),
                border: Border.all(
                  color: SavaioTheme.secondaryOf(context).withValues(
                    alpha: 0.24,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: SavaioTheme.secondaryGradientOf(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: SavaioTheme.onPrimaryFixedOf(context),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: SavaioTheme.spacingL),
                  Text(
                    '$streakCount',
                    style: textTheme.displayLarge?.copyWith(
                      color: SavaioTheme.onSurfaceOf(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    'Day Streak!',
                    style: textTheme.titleMedium?.copyWith(
                      color: SavaioTheme.secondaryOf(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SavaioTheme.spacing2xl),
            const AppSectionHeader(title: 'Apa itu Streak?'),
            const SizedBox(height: SavaioTheme.spacingL),
            _InfoCard(
              icon: Icons.check_circle_outline_rounded,
              title: 'Check-in Harian',
              description:
                  'Buka aplikasi setiap hari dan lakukan check-in untuk menambah streak kamu.',
            ),
            const SizedBox(height: SavaioTheme.spacingM),
            _InfoCard(
              icon: Icons.auto_graph_rounded,
              title: 'Konsistensi',
              description:
                  'Semakin panjang streak kamu, semakin baik kebiasaan finansialmu terbentuk.',
            ),
            const SizedBox(height: SavaioTheme.spacingM),
            _InfoCard(
              icon: Icons.emoji_events_rounded,
              title: 'Pencapaian',
              description:
                  'Dapatkan lencana spesial setiap kali kamu mencapai milestone streak tertentu.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(SavaioTheme.spacingXl),
      decoration: BoxDecoration(
        color: SavaioTheme.surfaceContainerLowOf(context),
        borderRadius: BorderRadius.circular(SavaioTheme.radiusL),
        border: Border.all(
          color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: SavaioTheme.primaryOf(context),
            size: 24,
          ),
          const SizedBox(width: SavaioTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: SavaioTheme.onSurfaceOf(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: SavaioTheme.spacingXs),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: SavaioTheme.onSurfaceVariantOf(context),
                    height: 1.45,
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