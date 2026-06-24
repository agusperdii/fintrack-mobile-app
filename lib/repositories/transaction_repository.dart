import 'package:savaio/models/app_data.dart';
import 'package:savaio/repositories/data_sources/remote/transaction_remote_data_source.dart';

class TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepository(this._remoteDataSource);

  Future<List<Transaction>> getTransactions({String? month}) {
    return _remoteDataSource.getTransactions(month: month);
  }

  Future<Transaction> createTransaction({
    required String title,
    String? description,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? receiptId,
    String source = 'manual',
  }) {
    return _remoteDataSource.createTransaction(
      title: title,
      description: description,
      amount: amount,
      categoryId: categoryId,
      date: date,
      receiptId: receiptId,
      source: source,
    );
  }

  Future<Transaction> updateTransaction({
    required String id,
    String? title,
    String? description,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? receiptId,
  }) {
    return _remoteDataSource.updateTransaction(
      id: id,
      title: title,
      description: description,
      amount: amount,
      categoryId: categoryId,
      date: date,
      receiptId: receiptId,
    );
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _remoteDataSource.deleteTransaction(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}