enum NotificationType { warning, info, streak, success }

class NotificationSegment {
  final String text;
  final bool isHighlighted;
  final bool isError;
  final bool isSuccess;

  const NotificationSegment({
    required this.text,
    this.isHighlighted = false,
    this.isError = false,
    this.isSuccess = false,
  });
}

class SuggestionData {
  final String label;
  final String title;
  final String iconType;

  const SuggestionData({
    required this.label,
    required this.title,
    required this.iconType,
  });
}

class NotificationData {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? extraData;

  const NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.extraData,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: _parseType(json['type']?.toString() ?? 'info'),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      extraData: json['extra_data'] as Map<String, dynamic>?,
    );
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      case 'warning': return NotificationType.warning;
      case 'success': return NotificationType.success;
      case 'streak': return NotificationType.streak;
      default: return NotificationType.info;
    }
  }
}
