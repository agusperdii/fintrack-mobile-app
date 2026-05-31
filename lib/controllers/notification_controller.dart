import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savaio/models/notification_data.dart';
import 'package:savaio/repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  List<NotificationData> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationData> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  NotificationData? get latestUnreadPopup {
    if (_notifications.isEmpty) return null;
    try {
      return _notifications.firstWhere(
        (n) => !n.isRead && (
          n.presentation == NotificationPresentation.popup ||
          n.presentation == NotificationPresentation.banner ||
          n.presentation == NotificationPresentation.toast
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final success = await _repository.markNotificationAsRead(id);
      if (success) {
        _notifications = _notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true, readAt: DateTime.now());
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
}
