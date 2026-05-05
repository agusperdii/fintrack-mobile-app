import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isTop;
  final bool isBottom;

  const AppProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.isTop = false,
    this.isBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(8) : Radius.zero,
            bottom: isBottom ? const Radius.circular(8) : Radius.zero,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: isTop ? null : Border(
                top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        icon, 
                        color: isDestructive ? colorScheme.error.withValues(alpha: 0.6) : colorScheme.onSurfaceVariant, 
                        size: 18
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppHeading(
                          title,
                          size: AppHeadingSize.subtitle,
                          color: isDestructive ? colorScheme.error.withValues(alpha: 0.8) : colorScheme.onSurface,
                          isBold: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.outline.withValues(alpha: 0.4),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
