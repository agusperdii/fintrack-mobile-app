import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/organisms/app_header.dart';

// Model internal untuk menangani tingkatan tipe pengguna secara dinamis
class UserStreakTier {
  final String title;
  final String statusBadge;
  final IconData icon;
  final List<Color> gradientColors;
  final int nextTargetDays;

  UserStreakTier({
    required this.title,
    required this.statusBadge,
    required this.icon,
    required this.gradientColors,
    required this.nextTargetDays,
  });
}

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  UserStreakTier _determineUserTier(int streakCount) {
    if (streakCount <= 3) {
      return UserStreakTier(
        title: 'Bronze Member',
        statusBadge: 'Basic',
        icon: Icons.shield_outlined,
        gradientColors: [Colors.amber.shade700, Colors.amber.shade900],
        nextTargetDays: 4,
      );
    } else if (streakCount <= 7) {
      return UserStreakTier(
        title: 'Silver Saver',
        statusBadge: 'Reguler',
        icon: Icons.shield_rounded,
        gradientColors: [Colors.blueGrey.shade400, Colors.blueGrey.shade700],
        nextTargetDays: 8,
      );
    } else if (streakCount <= 14) {
      return UserStreakTier(
        title: 'Gold Elite',
        statusBadge: 'Premium',
        icon: Icons.workspace_premium_rounded,
        gradientColors: [Colors.orange.shade400, Colors.orange.shade600],
        nextTargetDays: 15,
      );
    } else {
      return UserStreakTier(
        title: 'Diamond Sovereign',
        statusBadge: 'Eksklusif VIP',
        icon: Icons.diamond_rounded,
        gradientColors: [Colors.purple.shade400, Colors.indigo.shade700],
        nextTargetDays: 30,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final status = controller.checkInStatus;
    final streakCount = status?.streakCount ?? 0;
    final textTheme = Theme.of(context).textTheme;
    final tier = _determineUserTier(streakCount);

    final listDays = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final checkInHistory = [true, true, true, false, true, false, false];

    // Dummy social comparison
    final int percentile = 78;
    final bool aboveAverage = percentile >= 50;

    // UI Standard Tokens for Consistency
    const double cardRadius = SavaioTheme.radiusXl;
    const double innerPadding = SavaioTheme.spacingXl;
    const double elementSpacing = SavaioTheme.spacingXl;

    return Scaffold(
      backgroundColor: SavaioTheme.backgroundOf(context),
      appBar: const AppHeader(
        title: 'Streak Saya',
        showBackButton: true,
        showNotification: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SavaioTheme.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. MAIN STREAK CARD (HERO ELEMENT) =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: SavaioTheme.spacing2xl,
                horizontal: innerPadding,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SavaioTheme.secondaryOf(context).withValues(alpha: 0.12),
                    SavaioTheme.primaryOf(context).withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(
                  color: SavaioTheme.secondaryOf(context).withValues(alpha: 0.15),
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
                      boxShadow: [
                        BoxShadow(
                          color: SavaioTheme.secondaryOf(context).withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: SavaioTheme.onPrimaryFixedOf(context),
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: SavaioTheme.spacingM),
                  Text(
                    '$streakCount',
                    style: textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 64,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: SavaioTheme.spacingXs),
                  Text(
                    'Hari Beruntun!',
                    style: textTheme.titleMedium?.copyWith(
                      color: SavaioTheme.secondaryOf(context),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: elementSpacing),

            // ================= 2. USER TIER CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(innerPadding),
              decoration: BoxDecoration(
                color: SavaioTheme.surfaceContainerLowOf(context),
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SavaioTheme.spacingM),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: tier.gradientColors),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tier.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: SavaioTheme.spacingL),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipe Pengguna',
                              style: textTheme.bodySmall?.copyWith(
                                color: textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: SavaioTheme.spacingXs),
                            Text(
                              tier.title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SavaioTheme.spacingM,
                          vertical: SavaioTheme.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: tier.gradientColors.first.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(SavaioTheme.radiusM),
                        ),
                        child: Text(
                          tier.statusBadge,
                          style: textTheme.labelMedium?.copyWith(
                            color: tier.gradientColors.first,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SavaioTheme.spacingXl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        streakCount >= 15
                            ? 'Kamu berada di level tertinggi 🎉'
                            : 'Menuju tier berikutnya',
                        style: textTheme.bodyMedium?.copyWith(
                          color: textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        '$streakCount/${tier.nextTargetDays} Hari',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SavaioTheme.spacingM),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SavaioTheme.radiusS),
                    child: LinearProgressIndicator(
                      value: (streakCount / tier.nextTargetDays).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: SavaioTheme.surfaceContainerHighestOf(context),
                      valueColor: AlwaysStoppedAnimation<Color>(tier.gradientColors.first),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: elementSpacing),

            // ================= 3. WEEKLY TRACKER =================
            Container(
              padding: const EdgeInsets.all(innerPadding),
              decoration: BoxDecoration(
                color: SavaioTheme.surfaceContainerLowOf(context),
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final isDone = checkInHistory[index];
                  return Column(
                    children: [
                      Text(
                        listDays[index],
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDone 
                              ? SavaioTheme.primaryOf(context) 
                              : textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: SavaioTheme.spacingS),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDone
                              ? SavaioTheme.primaryOf(context)
                              : SavaioTheme.surfaceContainerHighestOf(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check_rounded : Icons.close_rounded,
                          size: 16,
                          color: isDone 
                              ? SavaioTheme.onPrimaryFixedOf(context) 
                              : textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: elementSpacing),

            // ================= 4. SOCIAL COMPARISON =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(innerPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    aboveAverage
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.orange.withValues(alpha: 0.08),
                    SavaioTheme.surfaceContainerLowOf(context),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(
                  color: aboveAverage
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(SavaioTheme.spacingM),
                    decoration: BoxDecoration(
                      color: aboveAverage
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      aboveAverage
                          ? Icons.trending_up_rounded
                          : Icons.insights_rounded,
                      color: aboveAverage ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: SavaioTheme.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aboveAverage
                              ? 'Konsistensimu di atas rata-rata!'
                              : 'Masih bisa ditingkatkan!',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: SavaioTheme.spacingS),
                        Text(
                          aboveAverage
                              ? 'Kamu lebih konsisten dibanding $percentile% pengguna Savaio minggu ini. Pertahankan streak-mu! 🔥'
                              : 'Saat ini kamu lebih konsisten dibanding $percentile% pengguna. Sedikit lagi untuk melampaui rata-rata 🚀',
                          style: textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}