import 'package:intl/intl.dart';

class SummaryUtils {
  /// Groups monthly summary data by year.
  static Map<String, List<Map<String, dynamic>>> groupByYear(List<Map<String, dynamic>> summary) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    // Sort summary by month descending (newest first)
    final sortedSummary = List<Map<String, dynamic>>.from(summary)
      ..sort((a, b) => (b['month'] as String).compareTo(a['month'] as String));

    for (var item in sortedSummary) {
      final monthStr = item['month'] as String? ?? '';
      final parts = monthStr.split('-');
      if (parts.isNotEmpty) {
        final year = parts[0];
        grouped.putIfAbsent(year, () => []).add(item);
      }
    }
    return grouped;
  }

  /// Formats a month string (YYYY-MM) to a readable format (e.g., April 2026).
  static String formatMonthYear(String monthYear) {
    try {
      final parts = monthYear.split('-');
      if (parts.length < 2) return monthYear;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return monthYear;
    }
  }

  /// Finds the maximum transaction count from a list of monthly summaries.
  static int getMaxTransactionCount(List<Map<String, dynamic>> summary) {
    int maxVal = 0;
    for (var item in summary) {
      final val = item['count'] as int? ?? 0;
      if (val > maxVal) maxVal = val;
    }
    return maxVal;
  }

  /// Calculates the relative progress ratio based on a current value and a maximum value.
  static double calculateRelativeProgress(num current, num max) {
    if (max <= 0) return 0.0;
    return (current / max).toDouble();
  }
}
