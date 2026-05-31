import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/app_data.dart';
import '../../../models/checkin_data.dart';
import '../../../models/notification_data.dart';

class DashboardRemoteDataSource {
  final ApiClient _client;

  DashboardRemoteDataSource(this._client);

  /// GET /dashboard/summary
  Future<AppData> getDashboard({String? month}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/dashboard/summary')
        .replace(queryParameters: month != null ? {'month': month} : null);
    final data = await _client.get(uri.toString()) as Map<String, dynamic>;
    return AppData.fromJson(data);
  }

  /// GET /notifications
  Future<List<NotificationData>> getNotifications({bool? isRead, String? type}) async {
    final params = <String, String>{};
    if (isRead != null) params['is_read'] = isRead.toString();
    if (type     != null) params['type']   = type;
    final uri = Uri.parse('${ApiConfig.baseUrl}/notifications')
        .replace(queryParameters: params.isNotEmpty ? params : null);
    final data = await _client.get(uri.toString()) as List? ?? [];
    return data.map((n) => NotificationData.fromJson(n as Map<String, dynamic>)).toList();
  }

  /// PATCH /notifications/:id/read
  Future<bool> markNotificationAsRead(String id) async {
    await _client.patch('${ApiConfig.baseUrl}/notifications/$id/read', body: {});
    return true;
  }

  /// DELETE /notifications/:id
  Future<bool> deleteNotification(String id) async {
    await _client.delete('${ApiConfig.baseUrl}/notifications/$id');
    return true;
  }

  /// GET /checkins/streak
  Future<CheckInStatus> getCheckInStatus() async {
    final data = await _client.get('${ApiConfig.baseUrl}/checkins/streak') as List? ?? [];
    return CheckInStatus.fromStreakJson(data);
  }

  /// POST /checkins
  Future<CheckInStatus> checkIn() async {
    // Record check-in
    await _client.post('${ApiConfig.baseUrl}/checkins', body: {});
    
    // API contract POST /checkins returns CheckInRecord, which doesn't have streak_count.
    // We fetch streak immediately after check-in to get updated status.
    return await getCheckInStatus();
  }
}
