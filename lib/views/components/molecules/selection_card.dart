import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SelectionCard extends StatelessWidget {
  final String label;
  final String value;
  final dynamic icon;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SavaioTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SavaioTheme.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: SavaioTheme.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  icon is IconData ? icon : Icons.category,
                  size: 16,
                  color: SavaioTheme.onSurface,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: SavaioTheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
