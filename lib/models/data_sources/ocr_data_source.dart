import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/config/api_config.dart';

class OcrDataSource {
  static const _timeout = Duration(seconds: 60);

  Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
    final uri = Uri.parse('${ApiConfig.ocrBaseUrl}/ocr/');
    
    final request = http.MultipartRequest('POST', uri);
    
    // Determine content type based on extension
    String extension = imageFile.path.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg'; // default
    if (extension == 'png') mimeType = 'image/png';
    if (extension == 'webp') mimeType = 'image/webp';

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType.parse(mimeType),
    ));

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse).timeout(_timeout);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal melakukan scan OCR: ${response.statusCode} ${response.body}');
    }
  }
}
