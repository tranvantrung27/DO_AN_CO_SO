import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImgbbService {
  static const String apiKey = 'b8125a3d511f96e3150542b3e689ebe9';

  static Future<String> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

      // Thêm timeout để tránh chờ quá lâu
      final request = http.MultipartRequest('POST', uri);

      // Thêm file vào request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Sử dụng timeout để tránh chờ quá lâu
      final response = await request.send().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timeout khi upload ảnh');
        },
      );

      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      // Parse JSON
      final jsonData = jsonDecode(responseString);

      if (jsonData['success'] == true) {
        return jsonData['data']['url'];
      } else {
        throw Exception('Upload thất bại: ${jsonData['error']}');
      }
    } catch (e) {
      debugPrint('Lỗi khi upload ảnh: $e');
      return ''; // Trả về chuỗi rỗng nếu có lỗi
    }
  }
}
