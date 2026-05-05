import 'package:flutter_test/flutter_test.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/others.dart';

void main() {
  group('AnalysisData Model Tests', () {
    test('AnalysisData.fromJson parses label correctly', () {
      final json = {'label': 'Food', 'amount': 150000.0, 'colorHex': 'FF4242'};
      final data = AnalysisData.fromJson(json);
      expect(data.label, 'Food');
      expect(data.amount, 150000.0);
      expect(data.colorHex, 'FF4242');
    });

    test('AnalysisData.fromJson handles null label with fallback', () {
      final json = {'label': null, 'amount': 75000.0, 'colorHex': null};
      final data = AnalysisData.fromJson(json);
      expect(data.label, 'Lainnya');
      expect(data.colorHex, '9E9E9E');
    });

    test('ParserUtils.toDouble converts String to double', () {
      expect(ParserUtils.toDouble('125000'), 125000.0);
      expect(ParserUtils.toDouble(null), 0.0);
      expect(ParserUtils.toDouble(50000), 50000.0);
    });

    test('AppData.balance computed correctly', () {
      final data = AppData(
        initialBalance: 1000000,
        totalIncome: 5000000,
        totalExpense: 2000000,
        recentTransactions: [],
        analysis: [],
      );
      // balance = initialBalance + totalIncome - totalExpense
      expect(data.balance, 4000000.0);
    });

    test('AppData analysis list is populated correctly', () {
      final analysis = [
        AnalysisData(label: 'Food', amount: 300000, colorHex: 'FF4242'),
        AnalysisData(label: 'Transport', amount: 150000, colorHex: '4285F4'),
      ];
      final data = AppData(
        initialBalance: 0,
        totalIncome: 1000000,
        totalExpense: 450000,
        recentTransactions: [],
        analysis: analysis,
      );
      expect(data.analysis.length, 2);
      expect(data.analysis[0].label, 'Food');
      expect(data.analysis[1].label, 'Transport');
    });

    test('Transaction.fromJson parses income type correctly', () {
      final json = {
        'id': 'tx-001',
        'title': 'Gaji',
        'amount': 5000000.0,
        'category': 'Salary',
        'date': '2026-05-01',
        'type': 'income',
      };
      final tx = Transaction.fromJson(json);
      expect(tx.type, TransactionType.income);
      expect(tx.amount, 5000000.0);
    });

    test('Transaction.fromJson parses expense type correctly', () {
      final json = {
        'id': 'tx-002',
        'title': 'Makan Siang',
        'amount': 50000.0,
        'category': 'Food',
        'date': '2026-05-02',
        'type': 'expense',
      };
      final tx = Transaction.fromJson(json);
      expect(tx.type, TransactionType.expense);
      expect(tx.category, 'Food');
    });
  });
}
