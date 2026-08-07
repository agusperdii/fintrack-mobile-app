// notification_repository.dart
// Repository untuk mengelola notifikasi pengguna: mengambil daftar,
// menandai sudah dibaca, dan menghapus notifikasi.

import 'package:savaio/models/notification_data.dart';
import 'package:savaio/repositories/data_sources/remote/dashboard_remote_data_source.dart';

class NotificationRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  NotificationRepository(this._remoteDataSource);

  Future<List<NotificationData>> getNotifications({bool? isRead, String? type}) {
    return _remoteDataSource.getNotifications(isRead: isRead, type: type);
  }

  Future<bool> markNotificationAsRead(String id) {
    return _remoteDataSource.markNotificationAsRead(id);
  }

  Future<bool> deleteNotification(String id) {
    return _remoteDataSource.deleteNotification(id);
  }
}
