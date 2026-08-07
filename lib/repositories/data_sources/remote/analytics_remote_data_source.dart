// analytics_remote_data_source.dart
// Data source yang berkomunikasi langsung dengan endpoint analytics dan
// summary di backend (data analitik, ringkasan tahunan/bulanan, dan
// export laporan).

import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/monthly_summary_model.dart';

class AnalyticsRemoteDataSource {
  final ApiClient _client;

  AnalyticsRemoteDataSource(this._client);

  /// GET /analytics — mengambil data analitik pengeluaran.
  Future<Map<String, dynamic>> getAnalytics({String? month}) async {
    final params = month != null ? {'month': month} : <String, String>{};
    final uri = Uri.parse('${ApiConfig.baseUrl}/analytics')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    return await _client.get(uri.toString()) as Map<String, dynamic>;
  }

  /// GET /summary?year=YYYY — mengambil ringkasan tahunan.
  Future<YearSummary> getYearSummary(int year) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/summary')
        .replace(queryParameters: {'year': year.toString()});

    final data = await _client.get(uri.toString()) as Map<String, dynamic>;
    return YearSummary.fromJson(data);
  }

  /// GET /summary/{month}/transactions — mengambil transaksi pada bulan tertentu.
  Future<MonthTransactions> getMonthTransactions(String month,
      {int page = 1, int limit = 20}) async {
    final params = {'page': page.toString(), 'limit': limit.toString()};
    final uri = Uri.parse('${ApiConfig.baseUrl}/summary/$month/transactions')
        .replace(queryParameters: params);

    final data = await _client.get(uri.toString()) as Map<String, dynamic>;
    return MonthTransactions.fromJson(data);
  }

  /// GET /summary/{month}/export?format=xlsx|pdf — membuat URL export laporan.
  /// DEPRECATED: Gunakan getExportToken untuk alur yang lebih aman.
  String getExportUrl(String month, String format) {
    return '${ApiConfig.baseUrl}/summary/$month/export?format=$format';
  }

  /// POST /summary/{month}/export-token?format=xlsx|pdf — mengambil token export laporan.
  Future<String> getExportToken(String month, String format) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/summary/$month/export-token')
        .replace(queryParameters: {'format': format});

    final data = await _client.post(uri.toString()) as Map<String, dynamic>;
    return data['token'] as String;
  }
}
