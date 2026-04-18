import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../atoms/app_heading.dart';

class AppSegmentToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const AppSegmentToggleButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? KineticVaultTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: AppHeading(
          label.toUpperCase(),
          size: AppHeadingSize.caption,
          color: isActive ? KineticVaultTheme.onPrimaryFixed : KineticVaultTheme.onSurfaceVariant,
          isBold: true,
        ),
      ),
    );
  }
}
