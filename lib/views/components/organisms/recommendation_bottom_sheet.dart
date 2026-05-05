import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/views/components/atoms/nudges/nudge_asymmetric_glow.dart';
import 'package:savaio/views/components/atoms/nudges/nudge_drag_handle.dart';
import 'package:savaio/views/components/molecules/nudges/nudge_illustration.dart';
import 'package:savaio/views/components/molecules/nudges/nudge_content.dart';
import 'package:savaio/views/components/molecules/nudges/nudge_action_buttons.dart';

class RecommendationBottomSheet extends StatelessWidget {
  final NudgeData nudge;
  final VoidCallback onDismiss;

  const RecommendationBottomSheet({
    super.key,
    required this.nudge,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SavaioTheme.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            top: -96,
            right: -96,
            child: NudgeAsymmetricGlow(),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const NudgeDragHandle(),
                const SizedBox(height: 32),
                const NudgeIllustration(
                  imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=2070&auto=format&fit=crop',
                ),
                const SizedBox(height: 24),
                NudgeContent(
                  title: 'Tips Hemat Hari Ini',
                  description: nudge.message,
                ),
                const SizedBox(height: 32),
                NudgeActionButtons(
                  primaryLabel: 'OKE',
                  onPrimaryTap: onDismiss,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, NudgeData nudge, VoidCallback onRead) {
    bool isHandled = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => RecommendationBottomSheet(
        nudge: nudge,
        onDismiss: () {
          if (isHandled) return;
          isHandled = true;
          onRead();
          Navigator.pop(context);
        },
      ),
    ).then((_) {
      if (!isHandled) {
        // Handle case where user dismisses by tapping outside/dragging down
        onRead();
      }
    });
  }
}
