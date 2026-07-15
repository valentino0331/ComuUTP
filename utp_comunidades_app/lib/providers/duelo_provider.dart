// filepath: utp_comunidades_app/lib/providers/duelo_provider.dart
import 'package:flutter/material.dart';
import '../models/liga.dart';
import '../services/api_service.dart';
import 'dart:convert';

class Pregunta {
  final int id;
  final int ronda;
  final String pregunta;
  final List<Map<String, dynamic>> opciones;
  final int? respuestaCorrecta;
  final String dificultad;
  final int tiempoLimite;

  Pregunta({
    required this.id,
    required this.ronda,
    required this.pregunta,
    required this.opciones,
    this.respuestaCorrecta,
    required this.dificultad,
    required this.tiempoLimite,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id'] as int,
      ronda: json['ronda'] as int,
      pregunta: json['pregunta'] as String,
      opciones: (jsonDecode(json['opciones'] as String) as List)
          .map((o) => Map<String, dynamic>.from(o))
          .toList(),
      respuestaCorrecta: json['respuesta_correcta'] as int?,
      dificultad: json['dificultad'] as String? ?? 'media',
      tiempoLimite: json['tiempo_limite'] as int? ?? 30,
    );
  }
}

class DueloProvider with ChangeNotifier {
  Duelo? _dueloActual;
  List<Pregunta> _preguntas = [];
  List<Duelo> _misDuelos = [];
  bool _loading = false;
  String? _error;
  int _dueloActualIndex = 0;

  Duelo? get dueloActual => _dueloActual;
  List<Pregunta> get preguntas => _preguntas;
  List<Duelo> get misDuelos => _misDuelos;
  bool get loading => _loading;
  String? get error => _error;
  int get dueloActualIndex => _dueloActualIndex;

  Pregunta? get preguntaActual =>
      _dueloActualIndex < _preguntas.length ? _preguntas[_dueloActualIndex] : null;

  // Iniciar duelo
  Future<bool> iniciarDuelo({
    required int ligaId,
    required int opponentId,
    required String tema,
    int? materialId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.post('/duelos/iniciar', {
        'liga_id': ligaId,
        'opponent_id': opponentId,
        'tema': tema,
        'material_id': materialId,
      }, auth: true);

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        _dueloActual = Duelo.fromJson(data['duelo']);
        await obtenerDuelo(_dueloActual!.id);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al iniciar duelo';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
    return false;
  }

  // Obtener duelo con preguntas
  Future<void> obtenerDuelo(int dueloId) async {
    try {
      final res = await ApiService.get('/duelos/$dueloId', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _dueloActual = Duelo.fromJson(data['duelo']);
        _preguntas = (data['preguntas'] as List)
            .map((p) => Pregunta.fromJson(p))
            .toList();
        _dueloActualIndex = 0;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  // Enviar respuesta
  Future<bool> enviarRespuesta({
    required int dueloId,
    required int preguntaId,
    required int respuestaSeleccionada,
    int? tiempoRespuesta,
  }) async {
    try {
      final res = await ApiService.post('/duelos/responder', {
        'duelo_id': dueloId,
        'duelo_pregunta_id': preguntaId,
        'respuesta_seleccionada': respuestaSeleccionada,
        'tiempo_respuesta': tiempoRespuesta ?? 15,
      }, auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        bool esCorrecta = data['es_correcta'] ?? false;

        // Actualizar puntos
        if (esCorrecta) {
          // Aquí se actualiza automáticamente en el backend
        }

        // Avanzar a siguiente pregunta
        if (_dueloActualIndex < _preguntas.length - 1) {
          _dueloActualIndex++;
        } else {
          // Finalizar duelo
          await finalizarDuelo(dueloId);
        }

        notifyListeners();
        return esCorrecta;
      } else {
        _error = 'Error al enviar respuesta';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    notifyListeners();
    return false;
  }

  // Finalizar duelo
  Future<void> finalizarDuelo(int dueloId) async {
    try {
      final res = await ApiService.post(
        '/duelos/$dueloId/finalizar',
        {},
        auth: true,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _dueloActual = Duelo.fromJson(data['duelo']);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  // Obtener mis duelos
  Future<void> fetchMisDuelos({int? ligaId, String? estado}) async {
    _loading = true;
    notifyListeners();

    try {
      String url = '/duelos/usuario/mis-duelos';
      List<String> params = [];
      if (ligaId != null) params.add('liga_id=$ligaId');
      if (estado != null) params.add('estado=$estado');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final res = await ApiService.get(url, auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _misDuelos = (data['duelos'] as List)
            .map((d) => Duelo.fromJson(d))
            .toList();
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
  }

  void reset() {
    _dueloActual = null;
    _preguntas = [];
    _dueloActualIndex = 0;
    notifyListeners();
  }
}
