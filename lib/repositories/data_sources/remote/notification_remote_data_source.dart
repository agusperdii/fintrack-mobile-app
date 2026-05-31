import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/notification_data.dart';

class NotificationRemoteDataSource {
  final ApiClient _client;

  NotificationRemoteDataSource(this._client);

  /// GET /notifications
  Future<List<NotificationData>> getNotifications({
    bool? isRead,
    String? type,
  }) async {
    final params = <String, String>{};
    if (isRead != null) params['is_read'] = isRead.toString();
    if (type != null) params['type'] = type;

    final uri = Uri.parse('${ApiConfig.baseUrl}/notifications')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final data = await _client.get(uri.toString()) as List? ?? [];
    return data.map((n) => NotificationData.fromJson(n as Map<String, dynamic>)).toList();
  }

  /// GET /notifications/popup
  Future<List<NotificationData>> getPopupNotifications() async {
    final data = await _client.get('${ApiConfig.baseUrl}/notifications/popup') as List? ?? [];
    return data.map((n) => NotificationData.fromJson(n as Map<String, dynamic>)).toList();
  }

  /// PATCH /notifications/{id}/read
  Future<void> markAsRead(String id) async {
    await _client.patch('${ApiConfig.baseUrl}/notifications/$id/read');
  }

  /// PATCH /notifications/read-all
  Future<int> markAllAsRead() async {
    final data = await _client.patch('${ApiConfig.baseUrl}/notifications/read-all') as Map<String, dynamic>;
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  /// DELETE /notifications/{id}
  Future<void> deleteNotification(String id) async {
    await _client.delete('${ApiConfig.baseUrl}/notifications/$id');
  }
}
