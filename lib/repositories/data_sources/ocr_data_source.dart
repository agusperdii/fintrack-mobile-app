import 'dart:io';
import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/ocr_result.dart';

class OcrDataSource {
  final ApiClient _apiClient;

  OcrDataSource(this._apiClient);

  /// POST /receipts — upload receipt image for OCR processing
  Future<OcrResult> uploadReceipt(File file) async {
    final data = await _apiClient.uploadFile(
      '${ApiConfig.baseUrl}/receipts',
      file,
    );
    return OcrResult.fromJson(data as Map<String, dynamic>);
  }

  /// GET /receipts/{id} — poll for OCR result
  Future<OcrResult> getReceipt(String id) async {
    final data = await _apiClient.get('${ApiConfig.baseUrl}/receipts/$id');
    return OcrResult.fromJson(data as Map<String, dynamic>);
  }

  /// GET /receipts — list all receipts
  Future<List<OcrResult>> getReceipts() async {
    final data = await _apiClient.get('${ApiConfig.baseUrl}/receipts');
    final list = data as List? ?? [];
    return list.map((r) => OcrResult.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// POST /receipts/{id}/confirm — create transaction from OCR data
  Future<OcrConfirmResult> confirmReceipt(
    String receiptId, {
    required String title,
    required double amount,
    required String date, // YYYY-MM-DD
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

  /// DELETE /receipts/{id}
  Future<void> deleteReceipt(String id) async {
    await _apiClient.delete('${ApiConfig.baseUrl}/receipts/$id');
  }
}
