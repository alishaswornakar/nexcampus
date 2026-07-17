import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class CloudinaryService {
  static const String cloudName = "rjij8wao";
  static const String uploadPreset = "nexcampus_assignments";

  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> uploadPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        return null;
      }

      final file = File(result.files.single.path!);

      final fileName = result.files.single.name;

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        "upload_preset": uploadPreset,
      });

      final response = await _dio.post(
        "https://console.cloudinary.com/app/c-46a97aa5001c5c1d382026a0398fd7/settings/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        return {
          "url": response.data["secure_url"],
          "name": fileName,
          "publicId": response.data["public_id"],
        };
      }

      throw Exception("Upload failed");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ?? e.message,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}