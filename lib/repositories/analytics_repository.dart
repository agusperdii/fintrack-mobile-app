import 'package:savaio/models/weekly_pulse_model.dart';
import 'package:savaio/models/monthly_summary_model.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/repositories/data_sources/remote/analytics_remote_data_source.dart';

class AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;
  List<MonthlySummaryModel>? _cachedSummary;

  AnalyticsRepository(this._remoteDataSource);

  Future<WeeklyPulseModel> getWeeklyPulse() async {
    final data = await _remoteDataSource.getAnalytics();
    return WeeklyPulseModel.fromJson(data);
  }

  Future<List<MonthlySummaryModel>> getMonthlySummary({int? year}) async {
    final summary = await getYearSummaryRaw(year: year);
    return summary.months;
  }

  Future<YearSummary> getYearSummaryRaw({int? year}) async {
    try {
      final summary = await _remoteDataSource.getYearSummary(year ?? DateTime.now().year);
      _cachedSummary = summary.months;
      return summary;
    } catch (e) {
      if (_cachedSummary != null) {
        return YearSummary(
          year: year ?? DateTime.now().year,
          currency: 'IDR',
          months: _cachedSummary!,
        );
      }
      rethrow;
    }
  }

  Future<List<AnalysisData>> getAnalysisData() async {
    final data = await _remoteDataSource.getAnalytics();
    final spending = data['categorySpending'] as List? ?? [];
    return spending.map((e) => AnalysisData.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getAnalyticsDataRaw({String? month}) async {
    return _remoteDataSource.getAnalytics(month: month);
  }

  /// DEPRECATED: Use getExportToken for the new secure flow.
  String getExportUrl(String month, String format) {
    return _remoteDataSource.getExportUrl(month, format);
  }

  Future<String> getExportToken(String month, String format) async {
    return _remoteDataSource.getExportToken(month, format);
  }

  Future<MonthTransactions> getMonthTransactions(String month, {int page = 1, int limit = 20}) {
    return _remoteDataSource.getMonthTransactions(month, page: page, limit: limit);
  }
}
