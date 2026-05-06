import 'package:savaio/models/notification_data.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/repositories/data_sources/remote/dashboard_remote_data_source.dart';

class NotificationRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  NotificationRepository(this._remoteDataSource);

  Future<List<NotificationData>> getNotifications() {
    return _remoteDataSource.getNotifications();
  }

  Future<bool> markNotificationRead(String id) {
    return _remoteDataSource.markNotificationRead(id);
  }

  Future<bool> deleteNotification(String id) {
    return _remoteDataSource.deleteNotification(id);
  }

  Future<List<NudgeData>> getNudges() {
    return _remoteDataSource.getNudges();
  }

  Future<bool> markNudgeRead(String id) {
    return _remoteDataSource.markNudgeRead(id);
  }
}
