import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/app_data.dart';

class TransactionRemoteDataSource {
  final ApiClient _client;

  TransactionRemoteDataSource(this._client);

  /// GET /transactions
  Future<List<Transaction>> getTransactions({
    String? month,
    String? categoryId,
    String? source,
    bool? isConfirmed,
    String? search,
  }) async {
    final params = <String, String>{};
    if (month       != null) params['month']        = month;
    if (categoryId != null) params['category_id']  = categoryId;
    if (source     != null) params['source']        = source;
    if (isConfirmed != null) params['is_confirmed'] = isConfirmed.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('${ApiConfig.baseUrl}/transactions')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final data = await _client.get(uri.toString()) as List? ?? [];
    return data.map((t) => Transaction.fromJson(t as Map<String, dynamic>)).toList();
  }

  /// GET /transactions/{id}
  Future<Transaction> getTransaction(String id) async {
    final data = await _client.get('${ApiConfig.baseUrl}/transactions/$id') as Map<String, dynamic>;
    return Transaction.fromJson(data);
  }

  /// POST /transactions
  /// Returns the created Transaction (from API response data).
  /// Throws on API error.
  Future<Transaction> createTransaction({
    required String title,
    String? description,
    required double amount,
    required DateTime date,
    String? categoryId,
    String? receiptId,
    String source = 'manual',
    bool isConfirmed = false,
  }) async {
    final offset = '+07:00';
    final isoDate = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}$offset';

    final body = <String, dynamic>{
      'title': title,
      'amount': amount,
      'date': isoDate,
      'source': source,
      'is_confirmed': isConfirmed,
    };
    if (description != null) body['description'] = description;
    if (categoryId != null) body['category_id'] = categoryId;
    if (receiptId != null) body['receipt_id'] = receiptId;

    // _unwrap already strips {success, message, data} → returns data directly
    final data = await _client.post(
      '${ApiConfig.baseUrl}/transactions',
      body: body,
    );
    return Transaction.fromJson(data as Map<String, dynamic>);
  }

  /// PATCH /transactions/{id}
  Future<Transaction> updateTransaction({
  required String id,
  String? title,
  String? description,
  double? amount,
  DateTime? date,
  String? categoryId,
  String? receiptId,
  bool? isConfirmed,
}) async {
  final body = <String, dynamic>{};

  if (title != null) body['title'] = title;
  if (description != null) body['description'] = description;
  if (amount != null) body['amount'] = amount;
  if (categoryId != null) body['category_id'] = categoryId;
  if (receiptId != null) body['receipt_id'] = receiptId;
  if (isConfirmed != null) body['is_confirmed'] = isConfirmed;

  if (date != null) {
    body['date'] = date.toIso8601String();
  }

  final data = await _client.patch(
    '${ApiConfig.baseUrl}/transactions/$id',
    body: body,
  );

  return Transaction.fromJson(data as Map<String, dynamic>);
}

  /// DELETE /transactions/{id}
  Future<void> deleteTransaction(String id) async {
    await _client.delete('${ApiConfig.baseUrl}/transactions/$id');
  }
}