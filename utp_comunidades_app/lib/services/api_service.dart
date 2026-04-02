import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Cambia por tu IP si usas dispositivo físico
  static final storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  static Future<void> saveToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  static Future<void> deleteToken() async {
    await storage.delete(key: 'token');
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> get(String endpoint, {bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }
}
