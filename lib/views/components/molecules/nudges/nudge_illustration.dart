import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/nudges/nudge_badge.dart';

class NudgeIllustration extends StatelessWidget {
  final String? imageUrl;
  final String badgeLabel;

  const NudgeIllustration({
    super.key, 
    this.imageUrl,
    this.badgeLabel = 'Expert Tip',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      image: true,
      label: 'Illustration for $badgeLabel',
      child: Container(
        width: double.infinity,
        height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            if (imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      size: 48,
                    ),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.surfaceContainerLow, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: NudgeBadge(label: badgeLabel),
            ),
          ],
        ),
      ),
    );
  }
}
