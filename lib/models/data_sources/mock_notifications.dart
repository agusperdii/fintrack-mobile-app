import '../entities/notification_data.dart';

class MockNotifications {
  static const List<NotificationData> notifications = [
    NotificationData(
      category: 'BUDGET ALERT',
      time: 'Baru saja',
      type: NotificationType.warning,
      contentSegments: [
        NotificationSegment(text: 'Batas harian hampir tercapai! Sisa '),
        NotificationSegment(text: 'Rp20.000', isError: true),
        NotificationSegment(text: ' untuk hari ini. Mau masak sendiri aja biar hemat?'),
      ],
      hasActions: true,
    ),
    NotificationData(
      category: 'SMART INSIGHT',
      time: '45 mnt lalu',
      type: NotificationType.info,
      contentSegments: [
        NotificationSegment(text: 'Wah, pengeluaran kopi kamu minggu ini naik '),
        NotificationSegment(text: '15%', isHighlighted: true),
        NotificationSegment(text: '. Coba kurangi 1 gelas buat nambah tabungan konsert!'),
      ],
    ),
    NotificationData(
      category: 'STREAK BONUS',
      time: '2 jam yang lalu',
      type: NotificationType.streak,
      plainContent: 'Jangan putus streak-nya! Catat pengeluaran makan siangmu sekarang dan dapatkan bonus poin.',
      streakProgress: 0.8,
      streakText: '4/5 Days',
    ),
    NotificationData(
      category: 'WEEKLY RECAP',
      time: 'Kemarin',
      type: NotificationType.success,
      contentSegments: [
        NotificationSegment(text: 'Laporan mingguan sudah siap. Kamu lebih hemat '),
        NotificationSegment(text: '10%', isSuccess: true),
        NotificationSegment(text: ' dari minggu lalu! Mantap!'),
      ],
      recapTitle: 'Efisiensi Belanja',
      recapAmount: '+Rp145k',
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
