import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationApiService {
  // Replace with your computer's IP address when testing on a phone/emulator.
  // Example: http://192.168.1.10:3000
  static const String baseUrl = "http://10.0.2.2:3000";

  Future<bool> sendToStudents({
    required String department,
    required String semester,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/sendToStudents"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "department": department,
          "semester": semester,
          "title": title,
          "body": body,
        }),
      );

      debugPrint((response.statusCode).toString());
      debugPrint(response.body);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
