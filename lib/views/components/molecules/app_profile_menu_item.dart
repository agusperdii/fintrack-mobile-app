import 'package:flutter/material.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';

class AppProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isTop;
  final bool isBottom;
  final Widget? trailing;

  const AppProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.isTop = false,
    this.isBottom = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(16) : Radius.zero,
          bottom: isBottom ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            border: isTop ? null : Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon, 
                    color: isDestructive 
                        ? Theme.of(context).colorScheme.error 
                        : Theme.of(context).colorScheme.onSurfaceVariant, 
                    size: 22
                  ),
                  const SizedBox(width: 16),
                  AppHeading(
                    title,
                    size: AppHeadingSize.subtitle,
                    color: isDestructive 
                        ? Theme.of(context).colorScheme.error 
                        : Theme.of(context).colorScheme.onSurface,
                    isBold: false,
                  ),
                ],
              ),
              trailing ?? Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}