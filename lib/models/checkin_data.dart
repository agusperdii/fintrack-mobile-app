// checkin_data.dart
// Model data untuk status dan riwayat check-in harian pengguna,
// termasuk logika perhitungan streak dan histori mingguan dari data check-in.

class CheckInStatus {
  final bool isCheckedInToday;
  final int streakCount;
  final DateTime? lastCheckinDate;
  final List<bool> history;
  final int percentile;

  CheckInStatus({
    required this.isCheckedInToday,
    required this.streakCount,
    this.lastCheckinDate,
    this.history = const [false, false, false, false, false, false, false],
    this.percentile = 0,
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
      history: json['history'] != null ? List<bool>.from(json['history']) : [false, false, false, false, false, false, false],
      percentile: json['percentile'] as int? ?? 0,
    );
  }

  /// Menghitung streak dari daftar tanggal check-in (YYYY-MM-DD)
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

    // Histori mingguan (7 hari terakhir, index 0 adalah 6 hari lalu, index 6 adalah hari ini)
    List<bool> history = List.generate(7, (index) {
      final d = now.subtract(Duration(days: 6 - index));
      final dStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      return dates.contains(dStr);
    });

    // Percentile perkiraan berdasarkan panjang streak
    int percentile = 25;
    if (streakCount >= 30) {
      percentile = 98;
    } else if (streakCount >= 14) {
      percentile = 88;
    } else if (streakCount >= 7) {
      percentile = 65;
    } else if (streakCount >= 3) {
      percentile = 45;
    }

    return CheckInStatus(
      isCheckedInToday: isCheckedInToday,
      streakCount: streakCount,
      lastCheckinDate: list.isNotEmpty ? DateTime.tryParse(dates.first) : null,
      history: history,
      percentile: percentile,
    );
  }
}

class CheckInRecord {
  final String id;
  final String? userId;
  /// Format YYYY-MM-DD
  final String checkinDate;
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
