import 'package:flutter/material.dart';

class NudgeGlowIcon extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final bool showBadge;
  final IconData badgeIcon;
  final String? semanticLabel;

  const NudgeGlowIcon({
    super.key, 
    required this.icon, 
    this.color,
    this.size = 80,
    this.showBadge = true,
    this.badgeIcon = Icons.priority_high_rounded,
    this.semanticLabel,
  });

  @override
  State<NudgeGlowIcon> createState() => _NudgeGlowIconState();
}

class _NudgeGlowIconState extends State<NudgeGlowIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = widget.color ?? colorScheme.secondary;
    final scale = widget.size / 80.0;

    return Semantics(
      label: widget.semanticLabel ?? 'Status icon',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse Glow
            FadeTransition(
              opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
              child: Container(
                width: 60 * scale,
                height: 60 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: effectiveColor.withValues(alpha: 0.3),
                      blurRadius: 30 * scale,
                      spreadRadius: 10 * scale,
                    ),
                  ],
                ),
              ),
            ),
            // Icon Container
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                widget.icon,
                color: effectiveColor,
                size: 40 * scale,
              ),
            ),
            // Error Badge
            if (widget.showBadge)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28 * scale,
                  height: 28 * scale,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surfaceContainer,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    widget.badgeIcon,
                    color: colorScheme.onError,
                    size: 14 * scale,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
