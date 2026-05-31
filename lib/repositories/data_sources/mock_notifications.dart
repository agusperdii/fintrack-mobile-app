import 'package:savaio/models/notification_data.dart';

class MockNotifications {
  static final List<NotificationData> notifications = [
    NotificationData(
      id: '1',
      title: 'BUDGET ALERT',
      message: 'Batas harian hampir tercapai! Sisa Rp20.000 untuk hari ini. Mau masak sendiri aja biar hemat?',
      type: NotificationType.warning,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      presentation: NotificationPresentation.banner,
      severity: NotificationSeverity.info,
    ),
    NotificationData(
      id: '2',
      title: 'SMART INSIGHT',
      message: 'Wah, pengeluaran kopi kamu minggu ini naik 15%. Coba kurangi 1 gelas buat nambah tabungan konsert!',
      type: NotificationType.info,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      presentation: NotificationPresentation.banner,
      severity: NotificationSeverity.info,
    ),
    NotificationData(
      id: '3',
      title: 'STREAK BONUS',
      message: 'Jangan putus streak-nya! Catat pengeluaran makan siangmu sekarang dan dapatkan bonus poin.',
      type: NotificationType.streak,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      presentation: NotificationPresentation.banner,
      severity: NotificationSeverity.info,
    ),
    NotificationData(
      id: '4',
      title: 'WEEKLY RECAP',
      message: 'Laporan mingguan sudah siap. Kamu lebih hemat 10% dari minggu lalu! Mantap!',
      type: NotificationType.success,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      presentation: NotificationPresentation.banner,
      severity: NotificationSeverity.info,
    ),
  ];

  static const List<dynamic> suggestions = [];
}
