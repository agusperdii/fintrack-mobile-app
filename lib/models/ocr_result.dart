// ocr_result.dart
// Model data untuk hasil OCR (Optical Character Recognition) pada struk belanja,
// termasuk data yang diekstrak dan hasil konfirmasi menjadi transaksi.

import '../../core/utils/parser_utils.dart';

/// Hasil OCR struk dari GET /receipts/{receipt_id}
/// dan parsed_data dari POST /receipts
class OcrResult {
  final String id;
  final String? userId;
  final String fileUrl;
  final String? ocrText;
  final ParsedReceiptData? parsedData;
  /// Status: 'processing', 'completed', 'failed', atau 'confirmed'
  final String status;
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OcrResult({
    required this.id,
    this.userId,
    required this.fileUrl,
    this.ocrText,
    this.parsedData,
    required this.status,
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
  });

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      fileUrl: json['file_url']?.toString() ?? '',
      ocrText: json['ocr_text']?.toString(),
      parsedData: json['parsed_data'] != null
          ? ParsedReceiptData.fromJson(json['parsed_data'] as Map<String, dynamic>)
          : null,
      status: json['status']?.toString() ?? 'processing',
      errorMessage: json['error_message']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isConfirmed => status == 'confirmed';
}

class ParsedReceiptData {
  final String? title;
  final double? amount;
  /// Format YYYY-MM-DD
  final String? date;
  final String? categoryId;
  final String? categorySuggestion;
  final String? merchantName;
  final String? description;

  ParsedReceiptData({
    this.title,
    this.amount,
    this.date,
    this.categoryId,
    this.categorySuggestion,
    this.merchantName,
    this.description,
  });

  factory ParsedReceiptData.fromJson(Map<String, dynamic> json) {
    return ParsedReceiptData(
      title: json['title']?.toString(),
      amount: json['amount'] != null ? ParserUtils.toDouble(json['amount']) : null,
      date: json['date']?.toString(),
      categoryId: json['category_id']?.toString(),
      categorySuggestion: json['category_suggestion']?.toString() ?? json['category']?.toString(),
      merchantName: json['merchant_name']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

/// Hasil dari POST /receipts/{receipt_id}/confirm
class OcrConfirmResult {
  final OcrResult receipt;
  final OcrTransaction transaction;

  OcrConfirmResult({required this.receipt, required this.transaction});

  factory OcrConfirmResult.fromJson(Map<String, dynamic> json) {
    return OcrConfirmResult(
      receipt: OcrResult.fromJson(json['receipt'] as Map<String, dynamic>),
      transaction: OcrTransaction.fromJson(json['transaction'] as Map<String, dynamic>),
    );
  }
}

/// Transaksi yang dibuat dari hasil konfirmasi OCR
class OcrTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String source;

  OcrTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.source,
  });

  factory OcrTransaction.fromJson(Map<String, dynamic> json) {
    return OcrTransaction(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: ParserUtils.toDouble(json['amount']),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      source: json['source']?.toString() ?? 'ocr',
    );
  }
}