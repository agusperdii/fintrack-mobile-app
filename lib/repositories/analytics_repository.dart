import 'package:savaio/models/weekly_pulse_model.dart';
import 'package:savaio/models/monthly_summary_model.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/repositories/data_sources/remote/analytics_remote_data_source.dart';

class AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;
  List<MonthlySummaryModel>? _cachedSummary;

  AnalyticsRepository(this._remoteDataSource);

  Future<WeeklyPulseModel> getWeeklyPulse() {
    return _remoteDataSource.getWeeklyPulse();
  }

  Future<List<MonthlySummaryModel>> getMonthlySummary() async {
    try {
      final data = await _remoteDataSource.getMonthlySummary();
      _cachedSummary = data;
      return data;
    } catch (e) {
      if (_cachedSummary != null) return _cachedSummary!;
      rethrow;
    }
  }

  Future<List<AnalysisData>> getAnalysisData() {
    return _remoteDataSource.getAnalysisData();
  }
}
