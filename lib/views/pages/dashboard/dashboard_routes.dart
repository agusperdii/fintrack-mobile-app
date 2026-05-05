import 'package:flutter/material.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/views/pages/transactions/add_transaction_page.dart';
import 'package:savaio/views/pages/transactions/all_transactions_page.dart';
import 'package:savaio/views/pages/dashboard/notifications_page.dart';
import 'package:savaio/views/pages/transactions/ocr_scan_page.dart';
import 'package:savaio/views/pages/dashboard/streak_page.dart';
import 'package:savaio/views/pages/transactions/transaction_detail_page.dart';

class DashboardRoutes {
  static void navigateToAddTransaction(BuildContext context, {required String type, String? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          initialType: type,
          initialCategory: category,
        ),
      ),
    );
  }

  static void navigateToAllTransactions(BuildContext context, List<Transaction> transactions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllTransactionsPage(
          initialTransactions: transactions,
        ),
      ),
    );
  }

  static void navigateToTransactionDetail(BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: transaction)),
    );
  }

  static void navigateToOcrScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OcrScanPage()),
    );
  }

  static void navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  static void navigateToStreak(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StreakPage()),
    );
  }
}
