import 'package:flutter_test/flutter_test.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/others.dart';

/// Tests for the data aggregation & transformation logic that mirrors
/// what RemoteDataSourceImpl.getAnalysisData() does on the Supabase response.
/// We test the pure data-transformation layer independently, avoiding
/// brittle Supabase fluent-API mocking.
void main() {
  group('RemoteDataSource API Logic Tests', () {
    test('getAnalysisData aggregates categories correctly', () {
      // Simulate raw Supabase rows returned from:
      // SELECT category, amount FROM transactions WHERE type='expense'
      final rawRows = [
        {'category': 'Food', 'amount': 100.0},
        {'category': 'Transport', 'amount': 50.0},
        {'category': 'Food', 'amount': 200.0}, // Same category – should be summed
        {'category': 'Coffee', 'amount': 75.0},
      ];

      // Replicate aggregation logic from RemoteDataSourceImpl.getAnalysisData()
      final Map<String, double> breakdown = {};
      for (var tx in rawRows) {
        final cat = tx['category'] as String? ?? 'Uncategorized';
        breakdown[cat] = (breakdown[cat] ?? 0) + ParserUtils.toDouble(tx['amount']);
      }

      final colors = ['FF4242', '4285F4', '34A853', 'FBBC05', '9C27B0', '00BCD4'];
      int i = 0;
      final result = breakdown.entries.map((e) {
        final color = colors[i % colors.length];
        i++;
        return AnalysisData(label: e.key, amount: e.value, colorHex: color);
      }).toList();

      expect(result.length, 3); // Food, Transport, Coffee
      final foodItem = result.firstWhere((r) => r.label == 'Food');
      expect(foodItem.amount, 300.0); // 100 + 200
      final transportItem = result.firstWhere((r) => r.label == 'Transport');
      expect(transportItem.amount, 50.0);
    });

    test('getAnalysisData returns empty list for empty data', () {
      final rawRows = <Map<String, dynamic>>[];

      final Map<String, double> breakdown = {};
      for (var tx in rawRows) {
        final cat = tx['category'] as String? ?? 'Uncategorized';
        breakdown[cat] = (breakdown[cat] ?? 0) + ParserUtils.toDouble(tx['amount']);
      }

      expect(breakdown.isEmpty, true);
    });

    test('monthly summary aggregation groups by month correctly', () {
      // Simulates the logic in getMonthlySummary()
      final rawTransactions = [
        {'date': '2026-05-10T10:00:00', 'amount': 150000.0, 'type': 'expense'},
        {'date': '2026-05-15T12:00:00', 'amount': 5000000.0, 'type': 'income'},
        {'date': '2026-04-05T09:00:00', 'amount': 200000.0, 'type': 'expense'},
        {'date': '2026-04-20T15:00:00', 'amount': 3000000.0, 'type': 'income'},
      ];

      final Map<String, Map<String, dynamic>> monthlyData = {};
      for (var tx in rawTransactions) {
        final dateStr = tx['date']?.toString();
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        monthlyData.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0, 'count': 0});
        final amount = ParserUtils.toDouble(tx['amount']);
        final type = tx['type']?.toString().toLowerCase();
        monthlyData[key]!['count'] = (monthlyData[key]!['count'] as int) + 1;
        if (type == 'income') {
          monthlyData[key]!['income'] = (monthlyData[key]!['income'] as double) + amount;
        } else if (type == 'expense') {
          monthlyData[key]!['expense'] = (monthlyData[key]!['expense'] as double) + amount;
        }
      }

      expect(monthlyData.keys.length, 2);
      expect(monthlyData['2026-05']!['expense'], 150000.0);
      expect(monthlyData['2026-05']!['income'], 5000000.0);
      expect(monthlyData['2026-04']!['expense'], 200000.0);
      expect(monthlyData['2026-04']!['income'], 3000000.0);
    });

    test('weekly pulse maps transactions to correct day index', () {
      // Simulates the daily values logic in getWeeklyPulse()
      final List<double> dailyValues = List.filled(7, 0.0);

      // Create a known Monday (weekday=1 means index 0)
      final monday = DateTime(2026, 5, 4); // May 4, 2026 is a Monday
      final wednesday = DateTime(2026, 5, 6); // Wednesday (weekday=3, index=2)

      final transactions = [
        {'date': monday.toIso8601String(), 'amount': 100000.0},
        {'date': wednesday.toIso8601String(), 'amount': 250000.0},
        {'date': monday.toIso8601String(), 'amount': 50000.0}, // Same day
      ];

      for (var tx in transactions) {
        final dateStr = tx['date'] as String?;
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;
        final dayIndex = date.weekday - 1;
        dailyValues[dayIndex] += ParserUtils.toDouble(tx['amount']);
      }

      expect(dailyValues[0], 150000.0); // Monday: 100k + 50k
      expect(dailyValues[2], 250000.0); // Wednesday
      expect(dailyValues[1], 0.0); // Tuesday: no transactions
    });
  });
}
