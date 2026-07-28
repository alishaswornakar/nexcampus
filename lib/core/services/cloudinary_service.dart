import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String _cloudName = "hyrruxkf";
  static const String _uploadPreset = "nex_campus";

  static Future<String?> uploadFile(File file) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$_cloudName/auto/upload",
      );

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['resource_type'] =
            'auto' // 👈 १. यहाँ resource_type थप्ने
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonMap = jsonDecode(responseData);

      if (response.statusCode == 200) {
        String? secureUrl = jsonMap['secure_url'] as String?;
        String format = jsonMap['format'] ?? '';

        // 💡 यदि PDF हो तर URL को अन्तिममा .pdf छैन भने थपिदिने
        if (secureUrl != null &&
            format == 'pdf' &&
            !secureUrl.endsWith('.pdf')) {
          secureUrl = "$secureUrl.pdf";
        }

        return secureUrl;
      } else {
        debugPrint("Cloudinary Upload Error: ${jsonMap['error']?['message']}");
        return null;
      }
    } catch (e) {
      debugPrint("Cloudinary Exception: $e");
      return null;
    }
  }
}
