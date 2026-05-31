import 'package:intl/intl.dart';
import 'package:savaio/models/monthly_summary_model.dart';

class SummaryUtils {
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

  static int getMaxTransactionCount(List<MonthlySummaryModel> summary) {
    int maxVal = 0;
    for (var item in summary) {
      final val = item.transactionCount;
      if (val > maxVal) maxVal = val;
    }
    return maxVal;
  }

  static double calculateRelativeProgress(num current, num max) {
    if (max <= 0) return 0.0;
    return (current / max).toDouble();
  }
}
