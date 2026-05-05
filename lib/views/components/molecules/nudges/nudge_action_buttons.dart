import 'package:flutter/material.dart';
import 'package:savaio/others.dart';

class NudgeActionButtons extends StatelessWidget {
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final String primaryLabel;
  final String? secondaryLabel;

  const NudgeActionButtons({
    super.key,
    required this.onPrimaryTap,
    this.onSecondaryTap,
    this.primaryLabel = 'Coba Sekarang',
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPrimaryTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: SavaioTheme.primaryGradient,
              borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
            ),
            child: Center(
              child: Text(
                primaryLabel,
                style: const TextStyle(
                  color: SavaioTheme.onPrimaryFixed,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        if (onSecondaryTap != null && secondaryLabel != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSecondaryTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: SavaioTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
              ),
              child: Center(
                child: Text(
                  secondaryLabel!,
                  style: const TextStyle(
                    color: SavaioTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
