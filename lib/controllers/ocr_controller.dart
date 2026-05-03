import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savaio/repositories/ocr_repository.dart';
import 'package:savaio/models/ocr_result.dart';

class OcrController with ChangeNotifier {
  final OcrRepository _repository;
  final ImagePicker _picker = ImagePicker();

  OcrController(this._repository);

  File? _selectedImage;
  bool _isLoading = false;
  OcrResult? _scanResult;
  String? _error;

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  OcrResult? get scanResult => _scanResult;
  String? get error => _error;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _selectedImage = File(image.path);
        _scanResult = null;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal mengambil gambar: $e';
      notifyListeners();
    }
  }

  Future<bool> startScan() async {
    if (_selectedImage == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _scanResult = await _repository.scanReceipt(_selectedImage!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Scan gagal: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _selectedImage = null;
    _scanResult = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
