import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/core/constants/api_config.dart';
import 'package:savaio/models/app_data.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/models/checkin_data.dart';

abstract class DashboardRemoteDataSource {
  Future<AppData> getDashboardData();
  Future<List<NudgeData>> getNudges();
  Future<bool> markNudgeRead(String id);
  Future<List<NotificationData>> getNotifications();
  Future<bool> markNotificationRead(String id);
  Future<bool> deleteNotification(String id);
  Future<CheckInStatus> getCheckInStatus();
  Future<bool> performCheckIn();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;
  final String baseUrl = ApiConfig.baseUrl;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AppData> getDashboardData() async {
    final response = await apiClient.get('$baseUrl/dashboard/');
    return AppData.fromJson(response);
  }

  @override
  Future<List<NudgeData>> getNudges() async {
    final response = await apiClient.get('$baseUrl/nudges/');
    return (response as List).map((n) => NudgeData.fromJson(n)).toList();
  }

  @override
  Future<bool> markNudgeRead(String id) async {
    await apiClient.put('$baseUrl/nudges/$id/read');
    return true;
  }

  @override
  Future<List<NotificationData>> getNotifications() async {
    final response = await apiClient.get('$baseUrl/notifications/');
    return (response as List).map((n) => NotificationData.fromJson(n)).toList();
  }

  @override
  Future<bool> markNotificationRead(String id) async {
    await apiClient.put('$baseUrl/notifications/$id', body: {'is_read': true});
    return true;
  }

  @override
  Future<bool> deleteNotification(String id) async {
    await apiClient.delete('$baseUrl/notifications/$id');
    return true;
  }

  @override
  Future<CheckInStatus> getCheckInStatus() async {
    final response = await apiClient.get('$baseUrl/check-in/status');
    return CheckInStatus.fromJson(response);
  }

  @override
  Future<bool> performCheckIn() async {
    await apiClient.post('$baseUrl/check-in/');
    return true;
  }
}
