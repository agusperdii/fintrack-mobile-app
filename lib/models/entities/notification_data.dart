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

class NotificationData {
  final String category;
  final String time;
  final NotificationType type;
  
  final List<NotificationSegment>? contentSegments;
  final String? plainContent;
  
  final bool hasActions;
  
  final double? streakProgress;
  final String? streakText;
  
  final String? recapTitle;
  final String? recapAmount;

  const NotificationData({
    required this.category,
    required this.time,
    required this.type,
    this.contentSegments,
    this.plainContent,
    this.hasActions = false,
    this.streakProgress,
    this.streakText,
    this.recapTitle,
    this.recapAmount,
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
