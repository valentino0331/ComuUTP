import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

class ApiService {
  // URL base - Se adapta según la plataforma
  static String get baseUrl {
    // Siempre usar Railway para evitar problemas de conexión en web
    return 'https://comuutp-production.up.railway.app/api';
  }
  
  static final storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    try {
      return await storage.read(key: 'token');
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      await storage.write(key: 'token', value: token);
    } catch (_) {
      // En web, flutter_secure_storage puede fallar, ignorar
    }
  }

  static Future<void> deleteToken() async {
    try {
      await storage.delete(key: 'token');
    } catch (_) {
      // En web, flutter_secure_storage puede fallar, ignorar
    }
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

  static Future<http.Response> delete(String endpoint, {bool auth = false, Map<String, dynamic>? body}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data, {bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data, {bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }
}
