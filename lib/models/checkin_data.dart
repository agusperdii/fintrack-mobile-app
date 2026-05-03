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
      isCheckedInToday: json['is_checked_in_today'],
      streakCount: json['streak_count'],
      lastCheckinDate: json['last_checkin_date'] != null 
          ? DateTime.parse(json['last_checkin_date']) 
          : null,
    );
  }
}
