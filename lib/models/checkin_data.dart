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
      isCheckedInToday: json['is_checked_in_today'] as bool? ?? false,
      streakCount: json['streak_count'] as int? ?? 0,
      lastCheckinDate: json['last_checkin_date'] != null 
          ? DateTime.tryParse(json['last_checkin_date']?.toString() ?? '') 
          : null,
    );
  }
}
