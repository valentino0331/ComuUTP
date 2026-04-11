import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

class ApiService {
  // URL del backend - CAMBIAR ESTA URL cuando despliegues en Railway/Render
  // Desarrollo local:
  // static const String _prodUrl = 'http://localhost:3000/api';
  // Producción Railway:
  static const String _prodUrl = 'https://comuutp-production.up.railway.app/api';

  static String get baseUrl {
    // Para desarrollo local (descomenta estas líneas si quieres usar localhost)
    // try {
    //   if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    //   return 'http://localhost:3000/api';
    // } catch (_) {
    //   return 'http://localhost:3000/api';
    // }
    
    // Usar URL de producción:
    return _prodUrl;
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
}
