import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/checkin_data.dart';
import 'package:savaio/repositories/data_sources/remote/dashboard_remote_data_source.dart';

class DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  AppData? _cachedDashboard;

  DashboardRepository(this._remoteDataSource);

  Future<AppData> getDashboardData() async {
    try {
      final data = await _remoteDataSource.getDashboardData();
      _cachedDashboard = data;
      return data;
    } catch (e) {
      if (_cachedDashboard != null) return _cachedDashboard!;
      rethrow;
    }
  }

  Future<CheckInStatus> getCheckInStatus() {
    return _remoteDataSource.getCheckInStatus();
  }

  Future<bool> performCheckIn() {
    return _remoteDataSource.performCheckIn();
  }
}
