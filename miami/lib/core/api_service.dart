import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // static const String baseUrl = "http://127.0.0.1:8000";
  static const String baseUrl = "http://10.2.48.64:8000"; // Android Emulator

  /// Fetch symptoms based on disease input
  static Future<List<String>> getSymptoms(String diseaseText) async {
    final Uri url = Uri.parse('$baseUrl/get_symptoms');

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"disease": diseaseText}),
          )
          .timeout(const Duration(seconds: 10)); // Prevents infinite waiting

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<String>.from(decoded);
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception(
            "Failed to load symptoms (Status: ${response.statusCode})");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in getSymptoms: $e");
      }
      return [];
    }
  }

  /// Submit selected symptoms
  static Future<List<String>> submitSymptoms(List<String> symptoms) async {
    final Uri url = Uri.parse('$baseUrl/submit_symptoms');

    try {
      final Map<String, dynamic> requestBody = {"symptoms": symptoms};
      final String jsonBody = jsonEncode(requestBody);
      print("Sending Symptoms: $jsonBody");
      if (kDebugMode) {
        print("Sending Symptoms: $jsonBody");
      } // ✅ Debugging log before sending

      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json; charset=UTF-8",
            },
            body: jsonBody, // ✅ Send UTF-8 encoded JSON
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print("🔹 Response Code: ${response.statusCode}");
      } // ✅ Debugging HTTP status
      if (kDebugMode) {
        print("🔹 Response Body: ${response.body}");
      } // ✅ Debugging actual response

      if (response.statusCode == 200) {
        print(response);
        //final decoded = jsonDecode(response.body);
        final decoded = jsonDecode(response.body);
        return List<String>.from(decoded);
      } else {
        if (kDebugMode) {
          print("Backend Rejected Symptoms. Response: ${response.body}");
        }
        return ["Error"];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in submitSymptoms: $e");
      }
      return ["Error"];
    }
  }
}
