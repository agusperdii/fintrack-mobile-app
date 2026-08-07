// selection_card.dart
// Widget molecule kartu pilihan (misalnya kategori atau akun) yang
// menampilkan label, ikon, dan nilai terpilih, dapat ditekan untuk diubah.

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
          color: SavaioTheme.surfaceContainerHighOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SavaioTheme.outlineVariantOf(context).withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: SavaioTheme.primaryOf(context),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildIcon(context),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: SavaioTheme.onSurfaceOf(context),
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

  Widget _buildIcon(BuildContext context) {
    if (icon is IconData) {
      return Icon(
        icon as IconData,
        size: 16,
        color: SavaioTheme.onSurfaceOf(context),
      );
    } else if (icon is String) {
      return Text(
        icon as String,
        style: const TextStyle(fontSize: 14),
      );
    }
    return Icon(Icons.category, size: 16, color: SavaioTheme.onSurfaceOf(context));
  }
}
