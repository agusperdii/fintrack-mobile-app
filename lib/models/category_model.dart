// category_model.dart
// Model data untuk kategori transaksi (pemasukan/pengeluaran) pengguna,
// termasuk konversi ke/dari JSON untuk komunikasi dengan API.

class CategoryModel {
  final String id;
  final String? userId;
  final String name;
  /// Tipe kategori: 'income' atau 'expense'
  final String type;
  /// Emoji atau nama ikon
  final String icon;
  final String color;
  final bool isDefault;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'expense',
      // API mengirim 'emoji', kode lama menggunakan 'icon'
      icon: json['emoji']?.toString() ?? json['icon']?.toString() ?? '📦',
      color: json['color']?.toString() ?? '#81ECFF',
      isDefault: json['is_default'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toRequestJson() => {
        'name': name,
        'type': type,
        'emoji': icon,
        'color': color,
      };
}