// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';


class CloudinaryService {
  static const String cloudName = "rjij8wao";
  static const String uploadPreset = "nexcampus_uploads";

  final Dio _dio = Dio();

  Future<Map<String, dynamic>> uploadFile(File file) async {
  try {
    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      "upload_preset": uploadPreset,
    });

    final response = await _dio.post(
      "https://api.cloudinary.com/v1_1/rjij8wao/image/upload",
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
Future<Map<String, dynamic>> uploadImage(
  File file,
) async {

  try {

    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({

      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),

      "upload_preset": uploadPreset,

    });


    final response = await _dio.post(

      "https://api.cloudinary.com/v1_1/rjij8wao/image/upload",

      data: formData,

    );


    if (response.statusCode == 200) {

      return {

        "url": response.data["secure_url"],

        "publicId": response.data["public_id"],

        "name": fileName,

      };

    }


    throw Exception(
      "Image upload failed",
    );

  } on DioException catch (e) {

    throw Exception(
      e.response?.data.toString() ??
          e.message,
    );

  } catch (e) {

    throw Exception(
      e.toString(),
    );

  }

}
}