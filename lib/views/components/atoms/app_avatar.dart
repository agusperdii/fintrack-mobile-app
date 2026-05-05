import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showBorder;
  final String? semanticLabel;
  final Widget? fallback;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.size = 80,
    this.showBorder = true,
    this.semanticLabel,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final effectiveFallback = fallback ?? Icon(
      Icons.person_rounded, 
      size: size * 0.5, 
      color: colorScheme.onSurfaceVariant,
    );

    return Semantics(
      image: true,
      label: semanticLabel ?? 'User Avatar',
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(1.5),
        decoration: showBorder ? BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ) : null,
        child: Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
            border: showBorder ? null : Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => effectiveFallback,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    );
                  },
                )
              : Center(child: effectiveFallback),
          ),
        ),
      ),
    );
  }
}
