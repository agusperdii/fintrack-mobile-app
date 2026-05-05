import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/views/components/atoms/nudges/nudge_glow_icon.dart';
import 'package:savaio/views/components/molecules/nudges/nudge_alert_content.dart';
import 'package:savaio/views/components/molecules/nudges/nudge_action_buttons.dart';

class NudgeAlertDialog extends StatelessWidget {
  final NudgeData nudge;
  final VoidCallback onDismiss;

  const NudgeAlertDialog({
    super.key,
    required this.nudge,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: SavaioTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: SavaioTheme.outlineVariant.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NudgeGlowIcon(
              icon: nudge.icon,
            ),
            const SizedBox(height: 32),
            NudgeAlertContent(
              title: 'Ouch!',
              message: nudge.message,
              progress: 0.9, // Mock 90% as per design
            ),
            const SizedBox(height: 40),
            NudgeActionButtons(
              primaryLabel: 'Lanjutkan',
              onPrimaryTap: onDismiss,
            ),
            const SizedBox(height: 24),
            Text(
              'This nudge is based on your monthly "Leisure" goal.'.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SavaioTheme.onSurfaceVariant.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, NudgeData nudge, VoidCallback onRead) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'NudgeAlert',
      barrierDismissible: true,
      barrierColor: SavaioTheme.surface.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => NudgeAlertDialog(
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
            scale: animation.drive(
              Tween<double>(begin: 0.8, end: 1.0).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
