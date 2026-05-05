import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/views/components/organisms/app_header.dart';
import 'package:savaio/views/components/molecules/app_section_header.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: sl.financeController,
      builder: (context, _) {
        final provider = sl.financeController;
        final status = provider.checkInStatus;
        final streakCount = status?.streakCount ?? 0;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppHeader(
            title: 'Kesehatan Finansial',
            showBackButton: true,
            showNotification: false,
            onBackTap: () => Navigator.pop(context),
            unreadCount: provider.unreadNotificationsCount,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Hero Streak Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.2),
                        Colors.orange.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$streakCount',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Day Streak!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const AppSectionHeader(title: 'Apa itu Streak?'),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Check-in Harian',
                  description: 'Buka aplikasi setiap hari dan lakukan check-in untuk menambah streak kamu.',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.auto_graph_rounded,
                  title: 'Konsistensi',
                  description: 'Semakin panjang streak kamu, semakin baik kebiasaan finansialmu terbentuk.',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.emoji_events_rounded,
                  title: 'Pencapaian',
                  description: 'Dapatkan lencana spesial setiap kali kamu mencapai milestone streak tertentu.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String description}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
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
