import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceEvidence> _evidences = [];
  List<Attendance> _userAttendances = [];
  bool _isLoading = false;
  String? _error;
  int _approvedAttendancesCount = 0;

  List<AttendanceEvidence> get evidences => _evidences;
  List<Attendance> get userAttendances => _userAttendances;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get approvedAttendancesCount => _approvedAttendancesCount;

  bool get canCreateCommunity => _approvedAttendancesCount >= 6;
  int get remainingAttendances => 6 - _approvedAttendancesCount;

  // Obtener evidencias del usuario actual
  Future<void> fetchUserEvidences(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/attendances/my-evidences'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _evidences = data.map((e) => AttendanceEvidence.fromJson(e)).toList();
        _calculateApprovedCount();
        _error = null;
      } else {
        _error = 'Error al cargar evidencias';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Subir nueva evidencia de asistencia
  Future<bool> submitEvidence({
    required String token,
    required File imageFile,
    required String tipoEvidencia,
    String? descripcion,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/attendances/submit-evidence'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['tipo_evidencia'] = tipoEvidencia;
      if (descripcion != null) {
        request.fields['descripcion'] = descripcion;
      }

      request.files.add(
        await http.MultipartFile.fromPath('evidencia', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        await fetchUserEvidences(token);
        _error = null;
        return true;
      } else {
        _error = json.decode(responseData)['error'] ?? 'Error al subir evidencia';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calcular asistencias aprobadas
  void _calculateApprovedCount() {
    _approvedAttendancesCount = _evidences.where((e) => e.estado == 'aprobada').length;
  }

  // ==================== ADMIN METHODS ====================

  List<AttendanceEvidence> _pendingEvidences = [];
  List<AttendanceEvidence> _allEvidences = [];
  Map<String, dynamic> _stats = {};

  List<AttendanceEvidence> get pendingEvidences => _pendingEvidences;
  List<AttendanceEvidence> get allEvidences => _allEvidences;
  Map<String, dynamic> get stats => _stats;

  // Obtener todas las evidencias pendientes (admin)
  Future<void> fetchPendingEvidences(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/attendances/pending'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _pendingEvidences = data.map((e) => AttendanceEvidence.fromJson(e)).toList();
        _error = null;
      } else {
        _error = 'Error al cargar evidencias pendientes';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aprobar o rechazar evidencia (admin)
  Future<bool> reviewEvidence({
    required String token,
    required int evidenceId,
    required bool approve,
    String? comentario,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/admin/attendances/review'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'evidence_id': evidenceId,
          'estado': approve ? 'aprobada' : 'rechazada',
          'comentario': comentario,
        }),
      );

      if (response.statusCode == 200) {
        await fetchPendingEvidences(token);
        await fetchAdminStats(token);
        _error = null;
        return true;
      } else {
        _error = 'Error al revisar evidencia';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener estadísticas del admin
  Future<void> fetchAdminStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/stats'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _stats = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  // Obtener todas las evidencias con filtros (admin)
  Future<void> fetchAllEvidences(String token, {String? estado}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String url = '${ApiService.baseUrl}/admin/attendances/all';
      if (estado != null) {
        url += '?estado=$estado';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allEvidences = data.map((e) => AttendanceEvidence.fromJson(e)).toList();
        _error = null;
      } else {
        _error = 'Error al cargar evidencias';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
