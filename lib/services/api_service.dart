// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.2.221:8000";
  static const String _tokenKey = "api_token";

  static String token = "";

  static Map<String, String> _authHeaders() {
    final token = ApiService.token;
    return {
      "Content-Type": "application/json",
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // Token persistence
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey) ?? "";
  }

  static Future<void> saveToken(String t) async {
    token = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, t);
  }

  static Future<void> clearToken() async {
    token = "";
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Map<String, String> authHeaders() => _authHeaders();

  // Signup
  static Future<bool> signup({
    required String username,
    required String password,
    String? fullName,
    String? email,
    int numCams = 1,
  }) async {
    final body = {
      "username": username,
      "password": password,
      "full_name": fullName,
      "email": email,
      "num_cams": numCams,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final js = jsonDecode(res.body);
      final t = js['token'] as String?;
      if (t != null) {
        await saveToken(t);
        return true;
      }
    }
    return false;
  }

  // Login
  static Future<bool> login(String user, String pass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": user, "password": pass}),
    );
    if (res.statusCode == 200) {
      final js = jsonDecode(res.body);
      final t = js['token'] as String?;
      if (t != null) {
        await saveToken(t);
        return true;
      }
    }
    return false;
  }

  static Future<void> logout() async {
    await clearToken();
  }

  // Current user
  static Future<Map<String, dynamic>> getCurrent() async {
    final res = await http.get(
      Uri.parse('$baseUrl/current'),
      headers: authHeaders(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch current user: ${res.statusCode}');
  }

  // Create camera (store the raw stream URL in DB)
  static Future<Map<String, dynamic>> createCamera({
    required String name,
    required String url,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cameras'),
      headers: authHeaders(),
      body: jsonEncode({"name": name, "url": url}),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create camera: ${res.statusCode} ${res.body}');
  }

  static Future<void> deleteCamera(String cameraId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/cameras/$cameraId'),
      headers: authHeaders(),
    );
    if (res.statusCode != 204) {
      final body = res.body.isNotEmpty ? res.body : 'status ${res.statusCode}';
      throw Exception('Failed to delete camera: $body');
    }
  }

  static Future<void> setDriverCam(String cameraId, bool isDriver) async {
    final res = await http.post(
      Uri.parse("$baseUrl/cameras/$cameraId/driver"),
      headers: _authHeaders(),
      body: jsonEncode({"is_driver": isDriver}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update driver cam: ${res.body}");
    }
  }

  /// register device token (FCM) to server
  static Future<void> registerDeviceToken(String deviceToken) async {
    final res = await http.post(
      Uri.parse("$baseUrl/devices/register"),
      headers: _authHeaders(),
      body: jsonEncode({"token": deviceToken}),
    );
    if (res.statusCode != 200) {
      throw Exception(
        "Failed to register device token: ${res.statusCode} ${res.body}",
      );
    }
  }

  static Future<void> unregisterDeviceToken(String deviceToken) async {
    final res = await http.post(
      Uri.parse("$baseUrl/devices/unregister"),
      headers: _authHeaders(),
      body: jsonEncode({"token": deviceToken}),
    );
    if (res.statusCode != 200) {
      throw Exception(
        "Failed to unregister device token: ${res.statusCode} ${res.body}",
      );
    }
  }

  // fetch notifications (optional)
  static Future<List<dynamic>> getNotifications() async {
    final res = await http.get(
      Uri.parse("$baseUrl/notifications"),
      headers: _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception(
        "Failed to fetch notifications: ${res.statusCode} ${res.body}",
      );
    }
    return jsonDecode(res.body) as List<dynamic>;
  }
}
