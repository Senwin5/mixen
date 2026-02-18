import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // ===========================
  // LOGIN
  // ===========================
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access']);
      return {"success": true, "data": data};
    } else {
      return {"success": false, "error": "Invalid username or password"};
    }
  }

  // ===========================
  // SIGNUP
  // ===========================
  static Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "email": email, "password": password}),
    );

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data.containsKey('access')) await saveToken(data['access']);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "error": data['error'] ?? "Signup failed"};
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Invalid response from server: ${response.body} (status code ${response.statusCode})"
      };
    }
  }

  // ===========================
  // SWIPE USERS
  // ===========================
  static Future<List<Map<String, dynamic>>> getSwipeUsers() async {
    String? token = await getToken();
    if (token == null) throw Exception("No token found. Login first.");

    final response = await http.get(
      Uri.parse("$baseUrl/swipe/"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) {
        final user = e as Map<String, dynamic>;
        return {
          "id": user['id'],
          "username": user['username'] ?? "Unknown",
          "age": user['age'] ?? "N/A",
          "bio": user['bio'] ?? "",
          "profile_image": user['profile_image'],
        };
      }).toList();
    } else {
      throw Exception("Failed to load users: ${response.body}");
    }
  }

  // ===========================
  // LIKE USER
  // ===========================
  static Future<Map<String, dynamic>> likeUser(int userId) async {
    String? token = await getToken();
    if (token == null) throw Exception("No token found. Login first.");

    final response = await http.post(
      Uri.parse("$baseUrl/like/"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({"to_user_id": userId}),
    );

    final data = jsonDecode(response.body);
    return {
      "success": response.statusCode == 201,
      "matched": data['success']?.toString().contains("match") ?? false,
      "error": data['error']
    };
  }

  // ===========================
  // UPLOAD PROFILE IMAGE
  // ===========================
  static Future<bool> uploadProfileImage(File file) async {
    String? token = await getToken();
    if (token == null) throw Exception("No token found. Login first.");

    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/upload-profile-image/"));
    request.headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath("image", file.path));

    final response = await request.send();
    return response.statusCode == 200;
  }

  // ===========================
  // UPDATE PROFILE
  // ===========================
  static Future<bool> updateProfile({
    required String bio,
    required int age,
    String? gender,
    String? location,
    int? height,
    bool drink = false,
    bool smoke = false,
    String? lookingFor,
  }) async {
    String? token = await getToken();
    if (token == null) throw Exception("No token found. Login first.");

    final response = await http.put(
      Uri.parse("$baseUrl/profile/"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({
        "bio": bio,
        "age": age,
        "gender": gender ?? "",
        "location": location ?? "",
        "height": height ?? 0,
        "drink": drink,
        "smoke": smoke,
        "looking_for": lookingFor ?? "",
      }),
    );

    return response.statusCode == 200;
  }
}
