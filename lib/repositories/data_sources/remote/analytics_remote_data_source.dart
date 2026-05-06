import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/core/constants/api_config.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/weekly_pulse_model.dart';
import 'package:savaio/models/monthly_summary_model.dart';
import 'package:savaio/core/utils/parser_utils.dart';

abstract class AnalyticsRemoteDataSource {
  Future<List<AnalysisData>> getAnalysisData();
  Future<WeeklyPulseModel> getWeeklyPulse();
  Future<List<MonthlySummaryModel>> getMonthlySummary();
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient apiClient;
  final String baseUrl = ApiConfig.baseUrl;

  AnalyticsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AnalysisData>> getAnalysisData() async {
    final response = await apiClient.get('$baseUrl/analytics/summary');
    final summary = response['category_breakdown'] as Map<String, dynamic>;
    final colors = ['FF4242', '4285F4', '34A853', 'FBBC05', '9C27B0', '00BCD4'];
    int i = 0;
    return summary.entries.map((e) {
      final color = colors[i % colors.length];
      i++;
      return AnalysisData(label: e.key, amount: ParserUtils.toDouble(e.value), colorHex: color);
    }).toList();
  }

  @override
  Future<WeeklyPulseModel> getWeeklyPulse() async {
    final response = await apiClient.get('$baseUrl/analytics/weekly-pulse');
    return WeeklyPulseModel.fromJson(response);
  }

  @override
  Future<List<MonthlySummaryModel>> getMonthlySummary() async {
    final response = await apiClient.get('$baseUrl/dashboard/monthly-summary');
    return (response['months'] as List).map((m) => MonthlySummaryModel.fromJson(m)).toList();
  }
}
