import 'dart:convert';

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
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "department": department,
          "semester": semester,
          "title": title,
          "body": body,
        }),
      );

      print(response.statusCode);
      print(response.body);

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }
}