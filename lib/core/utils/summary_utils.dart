import 'package:intl/intl.dart';
import 'package:savaio/models/monthly_summary_model.dart';

class SummaryUtils {
  /// Groups monthly summary data by year.
  static Map<String, List<MonthlySummaryModel>> groupByYear(List<MonthlySummaryModel> summary) {
    final Map<String, List<MonthlySummaryModel>> grouped = {};
    
    // Sort summary by month descending (newest first)
    final sortedSummary = List<MonthlySummaryModel>.from(summary)
      ..sort((a, b) => b.month.compareTo(a.month));

    for (var item in sortedSummary) {
      final monthStr = item.month;
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
  static int getMaxTransactionCount(List<MonthlySummaryModel> summary) {
    int maxVal = 0;
    for (var item in summary) {
      final val = item.transactionCount;
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
