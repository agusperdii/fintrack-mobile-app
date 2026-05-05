import 'package:flutter/material.dart';

class NudgeAnimatedRing extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final String? semanticLabel;
  final double size;

  const NudgeAnimatedRing({
    super.key, 
    required this.icon,
    this.color,
    this.semanticLabel,
    this.size = 120,
  });

  @override
  State<NudgeAnimatedRing> createState() => _NudgeAnimatedRingState();
}

class _NudgeAnimatedRingState extends State<NudgeAnimatedRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
    final effectiveColor = widget.color ?? colorScheme.tertiary;
    final scale = widget.size / 120.0;

    return Semantics(
      label: widget.semanticLabel ?? 'Animated notification',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Outer Ring
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 100 * scale,
                height: 100 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveColor.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 50 * scale - 4,
                      child: Container(
                        width: 8 * scale,
                        height: 8 * scale,
                        decoration: BoxDecoration(
                          color: effectiveColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: effectiveColor,
                              blurRadius: 10 * scale,
                              spreadRadius: 2 * scale,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Inner Static Ring
            Container(
              width: 70 * scale,
              height: 70 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: effectiveColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: effectiveColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(
                widget.icon,
                color: effectiveColor,
                size: 32 * scale,
              ),
            ),
            // Ambient Glow
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: effectiveColor.withValues(alpha: 0.05),
                    blurRadius: 40 * scale,
                    spreadRadius: 10 * scale,
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
