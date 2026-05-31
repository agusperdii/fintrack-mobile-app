import 'dart:io';
import 'package:savaio/repositories/data_sources/ocr_data_source.dart';
import 'package:savaio/models/ocr_result.dart';

class OcrRepository {
  final OcrDataSource _dataSource;

  OcrRepository(this._dataSource);

  Future<OcrResult> uploadReceipt(File imageFile) async {
    return _dataSource.uploadReceipt(imageFile);
  }
}
