import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class UserProfileStorageService {
  UserProfileStorageService({
    this.cloudName = 'daqkl6uc',
    this.uploadPreset = 'nexcampus_profiles',
  });

  final String cloudName;
  final String uploadPreset;

  Uri get _uploadUrl =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final request = http.MultipartRequest('POST', _uploadUrl)
        ..fields['upload_preset'] = uploadPreset
        // Unique public_id per upload — sidesteps the need for
        // 'overwrite', which unsigned uploads can't control anyway.
        ..fields['public_id'] = 'profile_images/$uid/$timestamp'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw UserProfileStorageException(
          'Cloudinary upload failed (${response.statusCode}): ${response.body}',
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String? secureUrl = data['secure_url'] as String?;

      if (secureUrl == null || secureUrl.isEmpty) {
        throw UserProfileStorageException(
          'Cloudinary upload succeeded but returned no URL.',
        );
      }

      return secureUrl;
    } on UserProfileStorageException {
      rethrow;
    } catch (e) {
      throw UserProfileStorageException(
        'An unexpected error occurred while uploading the profile image: $e',
      );
    }
  }

  /// Deletion requires a signed request (API secret) — not safe from
  /// a mobile app. Old images are simply left in Cloudinary; storage
  /// cost is negligible for small profile photos.
  Future<void> deleteOldImage(String? oldImageUrl) async {
    return;
  }
}

class UserProfileStorageException implements Exception {
  UserProfileStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
