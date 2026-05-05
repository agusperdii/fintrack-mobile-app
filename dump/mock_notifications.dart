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
      extraData: {
        'time': 'Baru saja',
        'hasActions': true,
      },
    ),
    NotificationData(
      id: '2',
      title: 'SMART INSIGHT',
      message: 'Wah, pengeluaran kopi kamu minggu ini naik 15%. Coba kurangi 1 gelas buat nambah tabungan konsert!',
      type: NotificationType.info,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      extraData: {
        'time': '45 mnt lalu',
      },
    ),
    NotificationData(
      id: '3',
      title: 'STREAK BONUS',
      message: 'Jangan putus streak-nya! Catat pengeluaran makan siangmu sekarang dan dapatkan bonus poin.',
      type: NotificationType.streak,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      extraData: {
        'time': '2 jam yang lalu',
        'streakProgress': 0.8,
        'streakText': '4/5 Days',
      },
    ),
    NotificationData(
      id: '4',
      title: 'WEEKLY RECAP',
      message: 'Laporan mingguan sudah siap. Kamu lebih hemat 10% dari minggu lalu! Mantap!',
      type: NotificationType.success,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      extraData: {
        'time': 'Kemarin',
        'recapTitle': 'Efisiensi Belanja',
        'recapAmount': '+Rp145k',
      },
    ),
  ];

  static const List<SuggestionData> suggestions = [
    SuggestionData(
      label: 'Wallet',
      title: 'Cek Saldo Gopay Kamu',
      iconType: 'wallet',
    ),
    SuggestionData(
      label: 'Vault',
      title: 'Target Konsert: 85%',
      iconType: 'vault',
    ),
  ];
}
