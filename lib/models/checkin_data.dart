class CheckInStatus {
  final bool isCheckedInToday;
  final int streakCount;
  final DateTime? lastCheckinDate;

  CheckInStatus({
    required this.isCheckedInToday,
    required this.streakCount,
    this.lastCheckinDate,
  });

  factory CheckInStatus.fromJson(Map<String, dynamic> json) {
    return CheckInStatus(
      isCheckedInToday: json['is_checked_in_today'] == true ||
          json['isCheckedInToday'] == true,
      streakCount: (json['streak_count'] as num? ??
              json['streakCount'] as num? ??
              0)
          .toInt(),
      lastCheckinDate: json['last_checkin_date'] != null
          ? DateTime.tryParse(json['last_checkin_date'].toString())
          : null,
    );
  }

  /// Calculates streak from a list of check-in dates (YYYY-MM-DD)
  factory CheckInStatus.fromStreakJson(List<dynamic> list) {
    if (list.isEmpty) {
      return CheckInStatus(isCheckedInToday: false, streakCount: 0);
    }

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final yesterday = now.subtract(const Duration(days: 1));

    bool isCheckedInToday = false;
    int streakCount = 0;

    final dates = list.map((e) => (e as Map<String, dynamic>)['checkin_date'].toString()).toSet();

    if (dates.contains(todayStr)) {
      isCheckedInToday = true;
    }

    // Calculate streak
    DateTime current = isCheckedInToday ? now : yesterday;
    while (true) {
      final dateStr = "${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}";
      if (dates.contains(dateStr)) {
        streakCount++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return CheckInStatus(
      isCheckedInToday: isCheckedInToday,
      streakCount: streakCount,
      lastCheckinDate: list.isNotEmpty ? DateTime.tryParse(dates.first) : null,
    );
  }
}

class CheckInRecord {
  final String id;
  final String? userId;
  final String checkinDate; // YYYY-MM-DD
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CheckInRecord({
    required this.id,
    this.userId,
    required this.checkinDate,
    this.createdAt,
    this.updatedAt,
  });

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    return CheckInRecord(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      checkinDate: json['checkin_date']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
