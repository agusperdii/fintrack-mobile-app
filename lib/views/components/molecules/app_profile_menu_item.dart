import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
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
    return Material(
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
              top: BorderSide(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon, 
                    color: isDestructive ? SavaioTheme.error.withValues(alpha: 0.6) : SavaioTheme.onSurfaceVariant, 
                    size: 18
                  ),
                  const SizedBox(width: 16),
                  AppHeading(
                    title,
                    size: AppHeadingSize.subtitle,
                    color: isDestructive ? SavaioTheme.error.withValues(alpha: 0.8) : SavaioTheme.onSurface,
                    isBold: false,
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: SavaioTheme.outline.withValues(alpha: 0.4),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
