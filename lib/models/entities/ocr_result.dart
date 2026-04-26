import '../../core/utils/parser_utils.dart';

class OcrResult {
  final String merchantName;
  final String merchantAddress;
  final String transactionDate;
  final String transactionTime;
  final double totalAmount;
  final List<OcrLineItem> lineItems;

  OcrResult({
    required this.merchantName,
    required this.merchantAddress,
    required this.transactionDate,
    required this.transactionTime,
    required this.totalAmount,
    required this.lineItems,
  });

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      merchantName: json['merchant_name']?.toString() ?? 'Merchant Tidak Diketahui',
      merchantAddress: json['merchant_address']?.toString() ?? '',
      transactionDate: json['transaction_date']?.toString() ?? '',
      transactionTime: json['transaction_time']?.toString() ?? '',
      totalAmount: ParserUtils.toDouble(json['total_amount']),
      lineItems: (json['line_items'] as List?)
              ?.map((item) => OcrLineItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OcrLineItem {
  final String itemName;
  final int itemQuantity;
  final double itemPrice;

  OcrLineItem({
    required this.itemName,
    required this.itemQuantity,
    required this.itemPrice,
  });

  factory OcrLineItem.fromJson(Map<String, dynamic> json) {
    return OcrLineItem(
      itemName: json['item_name']?.toString() ?? '',
      itemQuantity: (json['item_quantity'] as num?)?.toInt() ?? 0,
      itemPrice: ParserUtils.toDouble(json['item_price']),
    );
  }
}
