import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1),
      decoration: showBorder ? BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ) : null,
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
          border: showBorder ? null : Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: CircleAvatar(
          radius: (size / 2) - 2,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          backgroundColor: colorScheme.surfaceContainer,
          child: imageUrl.isEmpty ? Icon(Icons.person_rounded, size: size * 0.6, color: colorScheme.onSurfaceVariant) : null,
        ),
      ),
    );
  }
}
