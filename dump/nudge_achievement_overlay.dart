import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/views/components/atoms/nudges/nudge_large_icon.dart';
import 'package:savaio/views/components/atoms/nudges/nudge_stat_card.dart';

class NudgeAchievementOverlay extends StatelessWidget {
  final NudgeData nudge;
  final VoidCallback onDismiss;

  const NudgeAchievementOverlay({
    super.key,
    required this.nudge,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavaioTheme.background,
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SavaioTheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Icon
                  const NudgeLargeIcon(icon: Icons.emoji_events_rounded),
                  const SizedBox(height: 40),
                  
                  // Headline
                  const Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: SavaioTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "You've reached the Gold Tier Vault.",
                    style: TextStyle(
                      fontSize: 16,
                      color: SavaioTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Stats Grid
                  const NudgeStatCard(
                    label: 'Total Saved',
                    value: '\$4,850',
                    icon: Icons.trending_up,
                    accentColor: SavaioTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const NudgeStatCard(
                    label: 'Streaks',
                    value: '42',
                    icon: Icons.local_fire_department,
                    accentColor: SavaioTheme.secondary,
                  ),
                  
                  const Spacer(flex: 3),
                  
                  // Footer Action
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        color: SavaioTheme.primary,
                        borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
                        boxShadow: [
                          BoxShadow(
                            color: SavaioTheme.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'OKE',
                          style: TextStyle(
                            color: SavaioTheme.onPrimaryFixed,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Vault Identity Verified'.toUpperCase(),
                    style: TextStyle(
                      color: SavaioTheme.outline.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, NudgeData nudge, VoidCallback onRead) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: SavaioTheme.background,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => NudgeAchievementOverlay(
        nudge: nudge,
        onDismiss: () {
          onRead();
          Navigator.pop(context);
        },
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation.drive(Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          ),
        );
      },
    );
  }
}
