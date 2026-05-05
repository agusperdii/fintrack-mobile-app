import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savaio/others.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/views/components/atoms/nudges/nudge_animated_ring.dart';
import 'package:savaio/views/components/molecules/nudges/nudge_minimal_content.dart';

class NudgeToastOverlay extends StatefulWidget {
  final NudgeData nudge;
  final VoidCallback onDismiss;

  const NudgeToastOverlay({
    super.key,
    required this.nudge,
    required this.onDismiss,
  });

  @override
  State<NudgeToastOverlay> createState() => _NudgeToastOverlayState();

  static void show(BuildContext context, NudgeData nudge, VoidCallback onRead) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: SavaioTheme.background.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => NudgeToastOverlay(
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
            scale: animation.drive(Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack))),
            child: child,
          ),
        );
      },
    );
  }
}

class _NudgeToastOverlayState extends State<NudgeToastOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 1.2 seconds
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
          decoration: BoxDecoration(
            color: SavaioTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: SavaioTheme.tertiary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: SavaioTheme.tertiary.withValues(alpha: 0.1),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NudgeAnimatedRing(icon: Icons.check_circle_outline_rounded),
              const SizedBox(height: 32),
              NudgeMinimalContent(
                title: 'Sync Success',
                message: widget.nudge.message,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
