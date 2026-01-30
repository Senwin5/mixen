import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Change this depending on your setup:
  // Android emulator uses 10.0.2.2 to reach localhost
  static const String baseUrl = "http://10.0.2.2:8000/api"; 

  // Get token from shared preferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // SAVE TOKEN HERE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data['access']);

      return {
        "success": true,
        "data": data,
      };
    } else {
      return {
        "success": false,
        "error": "Invalid username or password",
      };
    }
  }


  

  // Get swipe users
  static Future<List<Map<String, dynamic>>> getSwipeUsers() async {
    String? token = await getToken();
    if (token == null) throw Exception("No token found. Login first.");

    final response = await http.get(
      Uri.parse("$baseUrl/swipe/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);

      // Ensure each user has profile_image, bio, and age
      return decoded.map((e) {
        final Map<String, dynamic> user = e as Map<String, dynamic>;
        return {
          "id": user['id'],
          "username": user['username'] ?? "Unknown",
          "age": user['age'] ?? "N/A",
          "bio": user['bio'] ?? "",
          "profile_image": user['profile_image'], // can be null
        };
      }).toList();
    } else {
      throw Exception("Failed to load users: ${response.body}");
    }
  }

  // Like user
  static Future<Map<String, dynamic>> likeUser(int userId) async {
    String? token = await getToken();
    if (token == null) throw Exception("No token found. Login first.");

    final response = await http.post(
      Uri.parse("$baseUrl/like/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"to_user_id": userId}),
    );

    final data = jsonDecode(response.body);

    return {
      "success": response.statusCode == 201,
      "matched": data['success']?.toString().contains("match") ?? false,
      "error": data['error']
    };
  }

  // Save token after login
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<dynamic> uploadProfileImage(File file) async {}

  static Future<dynamic> updateProfile({required String bio, required int age}) async {}
}
