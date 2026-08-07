// ocr_data_source.dart
// Data source yang berkomunikasi langsung dengan endpoint receipts di
// backend untuk fitur OCR struk belanja (upload, ambil hasil, konfirmasi
// jadi transaksi, dan hapus struk).

import 'dart:io';
import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/ocr_result.dart';

class OcrDataSource {
  final ApiClient _apiClient;

  OcrDataSource(this._apiClient);

  /// POST /receipts — mengunggah gambar struk untuk diproses OCR.
  Future<OcrResult> uploadReceipt(File file) async {
    final data = await _apiClient.uploadFile(
      '${ApiConfig.baseUrl}/receipts',
      file,
    );
    return OcrResult.fromJson(data as Map<String, dynamic>);
  }

  /// GET /receipts/{id} — polling hasil OCR.
  Future<OcrResult> getReceipt(String id) async {
    final data = await _apiClient.get('${ApiConfig.baseUrl}/receipts/$id');
    return OcrResult.fromJson(data as Map<String, dynamic>);
  }

  /// GET /receipts — mengambil daftar seluruh struk.
  Future<List<OcrResult>> getReceipts() async {
    final data = await _apiClient.get('${ApiConfig.baseUrl}/receipts');
    final list = data as List? ?? [];
    return list.map((r) => OcrResult.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// POST /receipts/{id}/confirm — membuat transaksi dari data hasil OCR.
  /// Format tanggal: YYYY-MM-DD.
  Future<OcrConfirmResult> confirmReceipt(
    String receiptId, {
    required String title,
    required double amount,
    required String date,
    String? categoryId,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'amount': amount,
      'date': date,
      'category_id': categoryId,
      'description': description,
    };

    final data = await _apiClient.post(
      '${ApiConfig.baseUrl}/receipts/$receiptId/confirm',
      body: body,
    );
    return OcrConfirmResult.fromJson(data as Map<String, dynamic>);
  }

  /// DELETE /receipts/{id} — menghapus struk.
  Future<void> deleteReceipt(String id) async {
    await _apiClient.delete('${ApiConfig.baseUrl}/receipts/$id');
  }
}
