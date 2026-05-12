import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5127';
  static const String _tokenKey = 'auth_token';

  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/User/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = _extractToken(response.body);
        if (token != null) {
          await _saveToken(token);
        }
        return null;
      } else {
        return _extractError(response.body);
      }
    } catch (e) {
      return 'خطأ في الاتصال بالسيرفر';
    }
  }

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/User/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = _extractToken(response.body);
        if (token != null) {
          await _saveToken(token);
        }
        return null;
      } else {
        return _extractError(response.body);
      }
    } catch (e) {
      return 'خطأ في الاتصال بالسيرفر';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  String? _extractToken(String body) {
    try {
      final data = jsonDecode(body);

      if (data is Map && data.containsKey('token')) {
        return data['token'];
      }

      if (data is String) {
        return data;
      }

      return null;
    } catch (_) {
      // fallback
      return body.replaceAll('"', '');
    }
  }

  String _extractError(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] ?? json.toString();
    } catch (_) {
      return body.isNotEmpty ? body : 'حصل خطأ غير معروف';
    }
  }
}