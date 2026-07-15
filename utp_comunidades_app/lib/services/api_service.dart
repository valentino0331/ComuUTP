import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;
import '../utils/constants.dart';

class ApiService {
  // URL base - Se adapta según la plataforma
  static String get baseUrl {
    return AppConstants.apiBaseUrl;
  }
  
  static final storage = FlutterSecureStorage();
  
  static bool isOfflineDemo = false;
  static List<Map<String, dynamic>>? _mockPosts;
  static List<Map<String, dynamic>>? _mockCommunities;
  
  // Callback para manejar deslogueos automáticos
  static Function(String message)? onUnauthorized;

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

  static Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      String message = 'Sesión expirada';
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? body['error'] ?? message;
      } catch (_) {}
      
      onUnauthorized?.call(message);
    }
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {bool auth = false}) async {
    if (isOfflineDemo) {
      return _mockRequest('POST', endpoint, data);
    }
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  static Future<http.Response> get(String endpoint, {bool auth = false}) async {
    if (isOfflineDemo) {
      return _mockRequest('GET', endpoint);
    }
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handleResponse(res);
  }

  static Future<http.Response> delete(String endpoint, {bool auth = false, Map<String, dynamic>? body}) async {
    if (isOfflineDemo) {
      return _mockRequest('DELETE', endpoint, body);
    }
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(res);
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data, {bool auth = false}) async {
    if (isOfflineDemo) {
      return _mockRequest('PUT', endpoint, data);
    }
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data, {bool auth = false}) async {
    if (isOfflineDemo) {
      return _mockRequest('PATCH', endpoint, data);
    }
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _handleResponse(res);
  }

  static void _initMockData() {
    _mockCommunities ??= [
      {
        "id": 1,
        "nombre": "Estudiantes de Sistemas UTP",
        "descripcion": "Comunidad oficial para compartir recursos de Ingeniería de Sistemas.",
        "miembros_count": 150,
        "usuario_creador_id": 1,
        "es_miembro": true
      },
      {
        "id": 2,
        "nombre": "Club de Programación",
        "descripcion": "Retos semanales y preparación para Hackathons.",
        "miembros_count": 89,
        "usuario_creador_id": 2,
        "es_miembro": true
      },
      {
        "id": 3,
        "nombre": "Deportes UTP",
        "descripcion": "Organización de torneos de fútbol, básquet y más.",
        "miembros_count": 210,
        "usuario_creador_id": 3,
        "es_miembro": false
      }
    ];

    _mockPosts ??= [
      {
        "id": 101,
        "usuario_id": 2,
        "comunidad_id": 1,
        "contenido": "Hola chicos! Recuerden que mañana vence el plazo para el laboratorio de Redes. ¿Alguien tiene el ejecutable de Packet Tracer?",
        "fecha": DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        "nombre_usuario": "Juan Perez",
        "nombre_comunidad": "Estudiantes de Sistemas UTP",
        "likes": 12,
        "comentarios": 4
      },
      {
        "id": 102,
        "usuario_id": 3,
        "comunidad_id": 2,
        "contenido": "¡Excelente taller de Flutter el día de hoy! Ya subí el código del repositorio a GitHub para que todos puedan revisarlo.",
        "fecha": DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        "nombre_usuario": "Maria Gomez",
        "nombre_comunidad": "Club de Programación",
        "likes": 25,
        "comentarios": 8
      },
      {
        "id": 103,
        "usuario_id": 22247388,
        "comunidad_id": 1,
        "contenido": "¡Hola a todos! Este es mi primer post en la comunidad local de UTP Comunidades.",
        "fecha": DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "nombre_usuario": "Valentino",
        "nombre_comunidad": "Estudiantes de Sistemas UTP",
        "likes": 5,
        "comentarios": 1
      }
    ];
  }

  static Future<http.Response> _mockRequest(String method, String endpoint, [Map<String, dynamic>? body]) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _initMockData();

    dynamic mockData;
    int statusCode = 200;

    // Quitar query params si existen
    final cleanEndpoint = endpoint.split('?').first;

    if (cleanEndpoint == '/auth/me') {
      mockData = {
        "id": 22247388,
        "email": "u22247388@utp.edu.pe",
        "nombre": "Valentino",
        "apellido": "Demo",
        "carrera": "Ingeniería de Sistemas",
        "ciclo": 5,
        "biografia": "Usuario predeterminado local (Sin servidor)",
        "foto_perfil": null,
        "postsCount": _mockPosts!.where((p) => p['usuario_id'] == 22247388).length,
        "comunidadesCount": _mockCommunities!.where((c) => c['es_miembro'] == true).length,
        "seguidoresCount": 42,
        "seguidosCount": 24,
        "es_premium": true,
        "puede_crear_comunidad": true,
        "role": "admin",
        "es_admin": true
      };
    } else if (cleanEndpoint.endsWith('/my-communities')) {
      mockData = {
        "comunidades": _mockCommunities!.where((c) => c['es_miembro'] == true).toList()
      };
    } else if (cleanEndpoint == '/communities' && method == 'GET') {
      mockData = {
        "comunidades": _mockCommunities
      };
    } else if (cleanEndpoint == '/communities' && method == 'POST') {
      final newCommunity = {
        "id": DateTime.now().millisecondsSinceEpoch,
        "nombre": body?['nombre'] ?? '',
        "descripcion": body?['descripcion'] ?? '',
        "miembros_count": 1,
        "usuario_creador_id": 22247388,
        "es_miembro": true
      };
      _mockCommunities!.add(newCommunity);
      mockData = {
        "success": true,
        "comunidad": newCommunity
      };
      statusCode = 201;
    } else if (cleanEndpoint == '/communities/join' && method == 'POST') {
      final communityId = body?['comunidad_id'];
      if (communityId != null) {
        final index = _mockCommunities!.indexWhere((c) => c['id'] == communityId);
        if (index != -1) {
          _mockCommunities![index]['es_miembro'] = true;
          _mockCommunities![index]['miembros_count'] = (_mockCommunities![index]['miembros_count'] ?? 0) + 1;
        }
      }
      mockData = {"success": true};
      statusCode = 200;
    } else if (cleanEndpoint == '/communities/leave' && method == 'POST') {
      final communityId = body?['comunidad_id'];
      if (communityId != null) {
        final index = _mockCommunities!.indexWhere((c) => c['id'] == communityId);
        if (index != -1) {
          _mockCommunities![index]['es_miembro'] = false;
          _mockCommunities![index]['miembros_count'] = (_mockCommunities![index]['miembros_count'] ?? 0) - 1;
        }
      }
      mockData = {"success": true};
      statusCode = 200;
    } else if (cleanEndpoint.startsWith('/communities/') && method == 'DELETE') {
      final parts = cleanEndpoint.split('/');
      final communityId = int.tryParse(parts.last) ?? 0;
      _mockCommunities!.removeWhere((c) => c['id'] == communityId);
      mockData = {"success": true};
      statusCode = 200;
    } else if (cleanEndpoint == '/posts' && method == 'GET') {
      mockData = {
        "publicaciones": _mockPosts
      };
    } else if (cleanEndpoint.startsWith('/posts/community/') && method == 'GET') {
      final parts = cleanEndpoint.split('/');
      final communityId = int.tryParse(parts.last) ?? 0;
      mockData = {
        "publicaciones": _mockPosts!.where((p) => p['comunidad_id'] == communityId).toList()
      };
    } else if (cleanEndpoint == '/posts' && method == 'POST') {
      final commId = body?['comunidad_id'] ?? 1;
      final comm = _mockCommunities!.firstWhere((c) => c['id'] == commId, orElse: () => _mockCommunities!.first);
      final newPost = {
        "id": DateTime.now().millisecondsSinceEpoch,
        "usuario_id": 22247388,
        "comunidad_id": commId,
        "contenido": body?['contenido'] ?? '',
        "fecha": DateTime.now().toIso8601String(),
        "nombre_usuario": "Valentino",
        "nombre_comunidad": comm['nombre'],
        "likes": 0,
        "comentarios": 0
      };
      _mockPosts!.insert(0, newPost);
      mockData = {
        "success": true,
        "publicacion": newPost
      };
      statusCode = 201;
    } else if (cleanEndpoint.startsWith('/posts/') && method == 'DELETE') {
      final parts = cleanEndpoint.split('/');
      final postId = int.tryParse(parts.last) ?? 0;
      _mockPosts!.removeWhere((p) => p['id'] == postId);
      mockData = {
        "success": true,
        "message": "Post deleted"
      };
      statusCode = 200;
    } else if (cleanEndpoint == '/likes' && method == 'POST') {
      final postId = body?['publicacion_id'];
      if (postId != null) {
        final index = _mockPosts!.indexWhere((p) => p['id'] == postId);
        if (index != -1) {
          _mockPosts![index]['likes'] = (_mockPosts![index]['likes'] ?? 0) + 1;
        }
      }
      mockData = {"success": true};
      statusCode = 200;
    } else if (cleanEndpoint == '/likes' && method == 'DELETE') {
      final postId = body?['publicacion_id'];
      if (postId != null) {
        final index = _mockPosts!.indexWhere((p) => p['id'] == postId);
        if (index != -1) {
          _mockPosts![index]['likes'] = (_mockPosts![index]['likes'] ?? 0) - 1;
        }
      }
      mockData = {"success": true};
      statusCode = 200;
    } else if (cleanEndpoint.startsWith('/messages/conversations')) {
      mockData = [
        {
          "id": 1,
          "nombre_otro_usuario": "Juan Perez",
          "ultimo_mensaje": "Hola Valentino, ¿cómo vas con el laboratorio?",
          "fecha_ultimo_mensaje": DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
          "no_leidos": 1
        },
        {
          "id": 2,
          "nombre_otro_usuario": "Maria Gomez",
          "ultimo_mensaje": "El taller de Flutter estuvo genial!",
          "fecha_ultimo_mensaje": DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          "no_leidos": 0
        }
      ];
    } else if (cleanEndpoint.contains('/messages/conversation')) {
      mockData = {
        "mensajes": [
          {
            "id": 1,
            "usuario_id": 2,
            "contenido": "Hola Valentino, ¿cómo vas con el laboratorio?",
            "fecha": DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String()
          },
          {
            "id": 2,
            "usuario_id": 22247388,
            "contenido": "Hola Juan, ya casi lo termino. ¿Y tú?",
            "fecha": DateTime.now().subtract(const Duration(minutes: 12)).toIso8601String()
          }
        ]
      };
    } else if (cleanEndpoint.startsWith('/notifications')) {
      mockData = {
        "notificaciones": [
          {
            "id": 1,
            "tipo": "like",
            "mensaje": "A Juan Perez le gustó tu publicación.",
            "leida": false,
            "fecha": DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()
          },
          {
            "id": 2,
            "tipo": "comment",
            "mensaje": "Maria Gomez comentó en tu publicación: '¡Excelente!'",
            "leida": true,
            "fecha": DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()
          }
        ]
      };
    } else if (cleanEndpoint.startsWith('/study/courses')) {
      mockData = {
        "courses": [
          {
            "id": "c1",
            "name": "Diseño y Desarrollo de Software",
            "course_code": "DDS-1234",
            "professor_name": "Ing. Carlos Torres",
            "description": "Curso obligatorio de 5to ciclo.",
            "semester": 1,
            "year": 2026
          },
          {
            "id": "c2",
            "name": "Redes de Computadoras I",
            "course_code": "REDES-5678",
            "professor_name": "Ing. Ana Lucía",
            "description": "Introducción al modelo OSI y TCP/IP.",
            "semester": 1,
            "year": 2026
          }
        ]
      };
    } else if (cleanEndpoint.startsWith('/ranking')) {
      mockData = {
        "ranking": [
          {"id": 1, "nombre": "Maria Gomez", "puntos": 1250, "puesto": 1},
          {"id": 2, "nombre": "Juan Perez", "puntos": 980, "puesto": 2},
          {"id": 22247388, "nombre": "Valentino (Tú)", "puntos": 750, "puesto": 3}
        ],
        "mi_posicion": {"id": 22247388, "nombre": "Valentino (Tú)", "puntos": 750, "puesto": 3}
      };
    } else {
      mockData = {"success": true, "message": "Simulated offline response"};
    }

    return http.Response(
      jsonEncode(mockData),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}
