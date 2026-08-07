// dashboard_repository.dart
// Repository untuk data dashboard utama dan status check-in harian
// pengguna, dengan fallback ke cache lokal saat request ke server gagal.

import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/checkin_data.dart';
import 'package:savaio/repositories/data_sources/remote/dashboard_remote_data_source.dart';

class DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  AppData? _cachedDashboard;

  DashboardRepository(this._remoteDataSource);

  Future<AppData> getDashboard() async {
    try {
      final data = await _remoteDataSource.getDashboard();
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

  Future<CheckInStatus> checkIn() {
    return _remoteDataSource.checkIn();
  }
}
