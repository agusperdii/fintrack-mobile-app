// notification_data.dart
// Model data untuk notifikasi dalam aplikasi (badge, banner, popup, toast),
// termasuk parsing tipe, severity, presentation, dan metadata dari JSON.

import 'dart:convert';

enum NotificationType {
  budgetReached,
  budgetExceeded,
  newTransaction,
  welcome,
  system,
  warning,
  info,
  streak,
  success,
  nudge,
}

enum NotificationSeverity { info, warning, danger }

enum NotificationPresentation { badge, banner, popup, toast }

class NotificationData {
  final String id;
  final String? userId;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationSeverity severity;
  final NotificationPresentation presentation;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationData({
    required this.id,
    this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.presentation,
    this.metadata,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    // metadata bisa berasal dari field 'metadata' (API) atau 'extra_data' (langsung dari Supabase DB realtime)
    final rawMetadata = json['metadata'] ?? json['extra_data'];
    Map<String, dynamic>? parsedMetadata;
    
    if (rawMetadata is Map) {
      parsedMetadata = Map<String, dynamic>.from(rawMetadata);
    } else if (rawMetadata is String && rawMetadata.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMetadata);
        if (decoded is Map) {
          parsedMetadata = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    return NotificationData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      type: _parseType(json['type']?.toString()),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      severity: _parseSeverity(json['severity']?.toString()),
      presentation: _parsePresentation(json['presentation']?.toString()),
      metadata: parsedMetadata,
      isRead: json['is_read'] == true,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static NotificationType _parseType(String? v) {
    switch (v) {
      case 'budget_reached':
        return NotificationType.budgetReached;
      case 'budget_exceeded':
        return NotificationType.budgetExceeded;
      case 'new_transaction':
        return NotificationType.newTransaction;
      case 'welcome':
        return NotificationType.welcome;
      case 'system':
        return NotificationType.system;
      case 'warning':
        return NotificationType.warning;
      case 'streak':
        return NotificationType.streak;
      case 'success':
        return NotificationType.success;
      case 'nudge':
        return NotificationType.nudge;
      default:
        return NotificationType.info;
    }
  }

  static NotificationSeverity _parseSeverity(String? v) {
    switch (v) {
      case 'warning':
        return NotificationSeverity.warning;
      case 'danger':
        return NotificationSeverity.danger;
      default:
        return NotificationSeverity.info;
    }
  }

  static NotificationPresentation _parsePresentation(String? v) {
    switch (v) {
      case 'banner':
        return NotificationPresentation.banner;
      case 'popup':
        return NotificationPresentation.popup;
      case 'toast':
        return NotificationPresentation.toast;
      default:
        return NotificationPresentation.badge;
    }
  }

  NotificationData copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationData(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      severity: severity,
      presentation: presentation,
      metadata: metadata,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}