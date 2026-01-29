import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://example.com"; // đổi thành server bạn

  static String token = "";

  static Future<bool> login(String user, String pass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": user, "password": pass}),
    );
    if (res.statusCode == 200) {
      token = jsonDecode(res.body)['token'];
      return true;
    }
    return false;
  }

  static Future<Map<String, dynamic>> getCurrent() async {
    final res = await http.get(
      Uri.parse('$baseUrl/current'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(res.body);
  }

  static Future<int> getNumCam() async {
    final res = await http.get(
      Uri.parse('$baseUrl/num_cam'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final js = jsonDecode(res.body);
    return js['num'];
  }

  static String camUrl(int id) => "$baseUrl/cam$id";
}
