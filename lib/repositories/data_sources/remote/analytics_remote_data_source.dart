import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/monthly_summary_model.dart';

class AnalyticsRemoteDataSource {
  final ApiClient _client;

  AnalyticsRemoteDataSource(this._client);

  /// GET /analytics
  Future<Map<String, dynamic>> getAnalytics({String? month}) async {
    final params = month != null ? {'month': month} : <String, String>{};
    final uri = Uri.parse('${ApiConfig.baseUrl}/analytics')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    return await _client.get(uri.toString()) as Map<String, dynamic>;
  }

  /// GET /summary?year=YYYY
  Future<YearSummary> getYearSummary(int year) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/summary')
        .replace(queryParameters: {'year': year.toString()});

    final data = await _client.get(uri.toString()) as Map<String, dynamic>;
    return YearSummary.fromJson(data);
  }

  /// GET /summary/{month}/transactions
  Future<MonthTransactions> getMonthTransactions(String month,
      {int page = 1, int limit = 20}) async {
    final params = {'page': page.toString(), 'limit': limit.toString()};
    final uri = Uri.parse('${ApiConfig.baseUrl}/summary/$month/transactions')
        .replace(queryParameters: params);

    final data = await _client.get(uri.toString()) as Map<String, dynamic>;
    return MonthTransactions.fromJson(data);
  }

  /// GET /summary/{month}/export?format=xlsx|pdf
  /// DEPRECATED: Use getExportToken instead for the new secure flow.
  String getExportUrl(String month, String format) {
    return '${ApiConfig.baseUrl}/summary/$month/export?format=$format';
  }

  /// POST /summary/{month}/export-token?format=xlsx|pdf
  Future<String> getExportToken(String month, String format) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/summary/$month/export-token')
        .replace(queryParameters: {'format': format});

    final data = await _client.post(uri.toString()) as Map<String, dynamic>;
    return data['token'] as String;
  }
}
