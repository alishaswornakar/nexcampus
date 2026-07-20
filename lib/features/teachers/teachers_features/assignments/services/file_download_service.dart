

import 'package:dio/dio.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloadService {
  static final Dio _dio = Dio();

  static Future<bool> downloadFile({
    required String url,
    required String fileName,
  }) async {
    try {
      final dir = await getTemporaryDirectory();

      final path = "${dir.path}/$fileName";

      await _dio.download(
        url,
        path,
      );

      final params = SaveFileDialogParams(
        sourceFilePath: path,
      );

      final savedPath =
          await FlutterFileDialog.saveFile(params: params);

      return savedPath != null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}