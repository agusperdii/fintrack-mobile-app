import 'package:savaio/models/app_data.dart';
import 'package:savaio/repositories/data_sources/remote/transaction_remote_data_source.dart';

class TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepository(this._remoteDataSource);

  Future<List<Transaction>> getTransactions({String? month}) {
    return _remoteDataSource.getTransactions(month: month);
  }

  Future<bool> addTransaction({
    required String title,
    String? description,
    required double amount,
    required String category,
    required String type,
    DateTime? date,
  }) {
    return _remoteDataSource.addTransaction(
      title: title,
      description: description,
      amount: amount,
      category: category,
      type: type,
      date: date,
    );
  }

  Future<bool> deleteTransaction(String id) {
    return _remoteDataSource.deleteTransaction(id);
  }
}
