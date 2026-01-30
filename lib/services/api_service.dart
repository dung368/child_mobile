// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl = "http://localhost:8000"; // đổi thành server bạn

//   static String token = "";

//   static Future<bool> login(String user, String pass) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({"username": user, "password": pass}),
//     );
//     if (res.statusCode == 200) {
//       token = jsonDecode(res.body)['token'];
//       return true;
//     }
//     return false;
//   }

//   static Future<Map<String, dynamic>> getCurrent() async {
//     final res = await http.get(
//       Uri.parse('$baseUrl/current'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//     return jsonDecode(res.body);
//   }

//   static Future<int> getNumCam() async {
//     final res = await http.get(
//       Uri.parse('$baseUrl/num_cam'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//     final js = jsonDecode(res.body);
//     return js['num'];
//   }

//   static String camUrl(int id) => "$baseUrl/cam$id";
// }
// lib/services/apiservices.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      "https://grandppltej2.loca.lt"; // đổi thành server bạn
  static const String _tokenKey = "api_token";

  static String token = "";

  // ---------- Token persistence ----------
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

  static Map<String, String> authHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ---------- Signup (new) ----------
  /// Sends username, password, optional full_name, email, num_cams
  /// Expects JSON { "user_id": "...", "token": "..." } on success.
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

  // ---------- Login ----------
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

  // ---------- Current user ----------
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

  // ---------- Number of cameras (per-user) ----------
  static Future<int> getNumCam() async {
    final res = await http.get(
      Uri.parse('$baseUrl/num_cam'),
      headers: authHeaders(),
    );
    if (res.statusCode == 200) {
      final js = jsonDecode(res.body);
      return js['num'] as int;
    }
    throw Exception('Failed to fetch num_cam: ${res.statusCode}');
  }

  /// Update authenticated user's number of cameras
  static Future<int> updateNumCam(int numberCam) async {
    final res = await http.post(
      Uri.parse('$baseUrl/num_cam_update'),
      headers: authHeaders(),
      body: jsonEncode({"number_cam": numberCam}),
    );
    if (res.statusCode == 200) {
      final js = jsonDecode(res.body);
      return js['num'] as int;
    }
    throw Exception('Failed to update num_cam: ${res.statusCode} ${res.body}');
  }

  // ---------- Camera info ----------
  /// Preferred: get camera metadata (uses auth)
  static Future<Map<String, dynamic>> getCamInfo(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/cam$id'),
      headers: authHeaders(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch cam info: ${res.statusCode}');
  }

  /// Convenience URL (but calls to /camX require Authorization header).
  static String camUrl(int id) => "$baseUrl/cam$id";
}
