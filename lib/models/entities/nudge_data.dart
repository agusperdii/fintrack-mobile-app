import 'package:flutter/material.dart';

enum NudgeType { warning, positive, reminder, info }

class NudgeData {
  final String id;
  final NudgeType type;
  final String? category;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NudgeData({
    required this.id,
    required this.type,
    this.category,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NudgeData.fromJson(Map<String, dynamic> json) {
    return NudgeData(
      id: json['id'] as String,
      type: _parseType(json['type']),
      category: json['category'] as String?,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Returns the category field if present, otherwise tries to extract it from the message.
  String? get targetCategory {
    if (category != null && category!.isNotEmpty) return category;
    
    // Fallback: Extract from message like "exceeds your budget for Food this month!"
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('budget for ')) {
      final startIndex = lowerMessage.indexOf('budget for ') + 'budget for '.length;
      final remaining = message.substring(startIndex);
      final words = remaining.split(' ');
      if (words.isNotEmpty) {
        // Return the word immediately after "budget for" (e.g. "Food")
        return words[0].replaceAll('!', '').replaceAll('.', '');
      }
    }
    return null;
  }

  static NudgeType _parseType(String? type) {
    switch (type) {
      case 'warning':
        return NudgeType.warning;
      case 'positive':
        return NudgeType.positive;
      case 'reminder':
        return NudgeType.reminder;
      default:
        return NudgeType.info; // Default fallback
    }
  }

  IconData get icon {
    switch (type) {
      case NudgeType.warning:
        return Icons.warning_amber_rounded;
      case NudgeType.positive:
        return Icons.stars_rounded;
      case NudgeType.reminder:
      case NudgeType.info:
        return Icons.notifications_active_rounded;
    }
  }
}
