import 'package:flutter/material.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/models/nudge_data.dart';
import 'package:savaio/repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  List<NotificationData> _notifications = [];
  List<NudgeData> _nudges = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationData> get notifications => _notifications;
  List<NudgeData> get nudges => _nudges;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  NudgeData? get latestUnreadNudge {
    if (_nudges.isEmpty) return null;
    try {
      return _nudges.firstWhere((n) => !n.isRead);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getNotifications(),
        _repository.getNudges(),
      ]);
      _notifications = results[0] as List<NotificationData>;
      _nudges = results[1] as List<NudgeData>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final success = await _repository.markNotificationRead(id);
      if (success) {
        _notifications = _notifications.map((n) {
          if (n.id == id) {
            return NotificationData(
              id: n.id,
              title: n.title,
              message: n.message,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
              extraData: n.extraData,
            );
          }
          return n;
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final success = await _repository.deleteNotification(id);
      if (success) {
        _notifications = _notifications.where((n) => n.id != id).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> markNudgeAsRead(String id) async {
    try {
      final success = await _repository.markNudgeRead(id);
      if (success) {
        _nudges = _nudges.map((n) {
          if (n.id == id) {
            return NudgeData(
              id: n.id,
              type: n.type,
              category: n.category,
              message: n.message,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking nudge as read: $e');
    }
  }
}
