import 'package:flutter/material.dart';
import 'package:savaio/others.dart';

class AnalisaMonthFilterSection extends StatelessWidget {
  final String selectedMonth;
  final Function(String) onMonthChanged;

  const AnalisaMonthFilterSection({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(4, (i) {
      final d = DateTime(now.year, now.month - i, 1);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = month == selectedMonth;
          return GestureDetector(
            onTap: () => onMonthChanged(month),
            child: AnimatedContainer(
              duration: SavaioTheme.durationFast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? SavaioTheme.primary.withValues(alpha: 0.15) : SavaioTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(SavaioTheme.radiusFull),
                border: Border.all(color: isSelected ? SavaioTheme.primary : SavaioTheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Text(
                _formatMonthLabel(month),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? SavaioTheme.primary : SavaioTheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatMonthLabel(String monthStr) {
    try {
      final parts = monthStr.split('-');
      if (parts.length < 2) return monthStr;
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final idx = int.parse(parts[1]);
      return '${months[idx]} ${parts[0]}';
    } catch (_) {
      return monthStr;
    }
  }
}
