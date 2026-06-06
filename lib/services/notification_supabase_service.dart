import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:savaio/models/notification_data.dart';

class NotificationSupabaseService {
  RealtimeChannel? _channel;
  final _controller = StreamController<NotificationData>.broadcast();
  String? _currentUserId;

  Stream<NotificationData> get notifications => _controller.stream;

  void subscribe(String userId) {
    if (_currentUserId == userId && _channel != null) return;
    
    _unsubscribe();
    _currentUserId = userId;

    debugPrint('[SupabaseWS] Listening to DB changes for user: $userId');
    
    _channel = Supabase.instance.client.channel('db-notifications-$userId');
    
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        debugPrint('[SupabaseWS] New DB Row Inserted: ${payload.newRecord}');
        try {
          final notification = NotificationData.fromJson(payload.newRecord);
          _controller.add(notification);
        } catch (e) {
          debugPrint('[SupabaseWS] Error parsing DB notification: $e');
        }
      },
    ).subscribe((status, [error]) {
      debugPrint('[SupabaseWS] DB Subscription status: $status');
      if (error != null) {
        debugPrint('[SupabaseWS] DB Subscription error: $error');
      }
    });
  }

  void _unsubscribe() {
    if (_channel != null) {
      debugPrint('[SupabaseWS] Unsubscribing from user-$_currentUserId');
      Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }
    _currentUserId = null;
  }

  void dispose() {
    _unsubscribe();
    _controller.close();
  }
}
