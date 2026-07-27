import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // तपाईंको Dashboard बाट लिइएको exact credentials
  static const String _cloudName = "hyrruxkf"; 
  static const String _uploadPreset = "nex_campus"; 

  static Future<String?> uploadFile(File file) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/auto/upload");
      
      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonMap = jsonDecode(responseData);

      if (response.statusCode == 200) {
        // Cloudinary ले दिएको secure URL (https://res.cloudinary.com/...)
        return jsonMap['secure_url'] as String?;
      } else {
        print("Cloudinary Upload Error: ${jsonMap['error']?['message']}");
        return null;
      }
    } catch (e) {
      print("Cloudinary Exception: $e");
      return null;
    }
  }
}