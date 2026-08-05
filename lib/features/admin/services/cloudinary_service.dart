import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String cloudName = 'hyrruxkf';
  static const String uploadPreset = 'mykmmiaw';

  static Future<String?> uploadFile(File file) async {
    try {
      // फाइलको नाम र एक्सटेन्सन चेक गर्ने
      String filePath = file.path.toLowerCase();
      String resourceType = 'auto'; // Default

      // यदि पीडीएफ वा डकुमेन्ट हो भने Cloudinary मा 'raw' वा 'image' छुट्टाइदिनुपर्छ
      if (filePath.endsWith('.pdf') ||
          filePath.endsWith('.doc') ||
          filePath.endsWith('.docx')) {
        resourceType =
            'raw'; // 👈 PDF र Docs को लागि 'raw' प्रयोग गर्दा शतप्रतिशत काम गर्छ
      } else if (filePath.endsWith('.jpg') ||
          filePath.endsWith('.jpeg') ||
          filePath.endsWith('.png')) {
        resourceType = 'image';
      }

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final resultString = String.fromCharCodes(responseData);

      debugPrint("Cloudinary Status Code: ${response.statusCode}");
      debugPrint("Cloudinary Response Body: $resultString");

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(resultString);
        return jsonMap['secure_url']; // ✅ सफल भएपछि URL फिर्ता आउँछ
      } else {
        debugPrint("Cloudinary Upload Failed: $resultString");
      }
    } catch (e) {
      debugPrint("Cloudinary Exception: $e");
    }
    return null;
  }
}
