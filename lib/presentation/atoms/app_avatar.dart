import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool showBorder;

  const AppAvatar({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1),
      decoration: showBorder ? const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [KineticVaultTheme.primary, KineticVaultTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ) : null,
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: KineticVaultTheme.surface,
          border: showBorder ? null : Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: CircleAvatar(
          radius: (size / 2) - 2,
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: KineticVaultTheme.surfaceContainer,
        ),
      ),
    );
  }
}
