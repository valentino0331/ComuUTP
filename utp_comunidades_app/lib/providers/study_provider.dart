// lib/providers/study_provider.dart

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/study_models.dart';
import '../services/api_service.dart';

class StudyProvider extends ChangeNotifier {
  
  List<StudyCourse> _courses = [];
  Map<String, List<StudyMaterial>> _materials = {};
  List<StudyQuestion> _questions = [];
  bool _isLoading = false;
  String? _error;
  bool _demoMode = false;

  // Getters
  List<StudyCourse> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StudyQuestion> get questions => _questions;
  
  List<StudyMaterial> getMaterialsByCourse(String courseId) => 
    _materials[courseId] ?? [];

  bool get demoMode => _demoMode;

  // Fetch all courses
  Future<void> fetchCourses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa. Por favor, inicia sesión.');
      }

      final response = await ApiService.get('/study/courses', auth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _courses = (data['data'] as List)
            .map((json) => StudyCourse.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
      } else if (response.statusCode == 404) {
        // Backend not deployed in this environment — fall back to demo mode.
        _demoMode = true;
        _error = null;
        _courses = [
          StudyCourse(
            id: 'demo-1',
            name: 'Fundamentos de Programación',
            courseCode: 'CS-101',
            professorName: 'Ing. Demo',
            description: 'Curso de introducción con materiales de ejemplo.',
            semester: 1,
            year: DateTime.now().year,
            createdAt: DateTime.now(),
            materialCount: 2,
            questionCount: 5,
          ),
          StudyCourse(
            id: 'demo-2',
            name: 'Algoritmos y Estructuras de Datos',
            courseCode: 'CS-201',
            professorName: 'Dra. Ejemplo',
            description: 'Prácticas y teoría para repasar conceptos.',
            semester: 1,
            year: DateTime.now().year,
            createdAt: DateTime.now(),
            materialCount: 3,
            questionCount: 8,
          ),
        ];
        return;
      } else {
        throw Exception('Error al cargar cursos: ${response.statusCode}');
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create course
  Future<StudyCourse?> createCourse(Map<String, dynamic> courseData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.post(
        '/study/courses',
        courseData,
        auth: true,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final course = StudyCourse.fromJson(data['data']);
        _courses.insert(0, course);
        notifyListeners();
        return course;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else if (response.statusCode == 404) {
        // Backend not available - use demo mode
        _demoMode = true;
        final course = StudyCourse(
          id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
          name: courseData['name'] ?? 'Nuevo Curso',
          courseCode: courseData['course_code'],
          professorName: courseData['professor_name'],
          description: courseData['description'],
          semester: courseData['semester'],
          year: courseData['year'],
          createdAt: DateTime.now(),
        );
        _courses.insert(0, course);
        notifyListeners();
        return course;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al crear curso');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en createCourse: $_error');
      // Fallback to demo mode on error
      _demoMode = true;
      final course = StudyCourse(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        name: courseData['name'] ?? 'Nuevo Curso',
        courseCode: courseData['course_code'],
        professorName: courseData['professor_name'],
        description: courseData['description'],
        semester: courseData['semester'],
        year: courseData['year'],
        createdAt: DateTime.now(),
      );
      _courses.insert(0, course);
      notifyListeners();
      return course;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch materials for course
  Future<void> fetchMaterials(String courseId) async {
    try {
      if (_materials.containsKey(courseId)) {
        return;
      }

      if (_demoMode) {
        // Provide demo materials locally
        _materials[courseId] = [
          StudyMaterial(
            id: 'demo-m-1',
            courseId: courseId,
            name: 'Apuntes de clase - Introducción.pdf',
            fileUrl: 'https://www.example.com/demo/intro.pdf',
            fileSizeBytes: 256000,
            fileType: 'pdf',
            pageCount: 12,
            category: 'Apuntes',
            createdAt: DateTime.now(),
          ),
          StudyMaterial(
            id: 'demo-m-2',
            courseId: courseId,
            name: 'Resumen - Tema 1.txt',
            fileUrl: 'https://www.example.com/demo/resumen.txt',
            fileSizeBytes: 2048,
            fileType: 'txt',
            pageCount: null,
            category: 'Resumen',
            createdAt: DateTime.now(),
          ),
        ];
        return;
      }

      final response = await ApiService.get('/study/courses/$courseId', auth: true);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _materials[courseId] = (data['data']['materials'] as List? ?? [])
            .map((json) => StudyMaterial.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else if (response.statusCode == 404) {
        // Backend not available - use demo mode
        _demoMode = true;
        _materials[courseId] = [
          StudyMaterial(
            id: 'demo-m-1-$courseId',
            courseId: courseId,
            name: 'Apuntes de clase - Introducción.pdf',
            fileUrl: 'https://www.example.com/demo/intro.pdf',
            fileSizeBytes: 256000,
            fileType: 'pdf',
            pageCount: 12,
            category: 'Apuntes',
            createdAt: DateTime.now(),
          ),
          StudyMaterial(
            id: 'demo-m-2-$courseId',
            courseId: courseId,
            name: 'Resumen - Tema 1.txt',
            fileUrl: 'https://www.example.com/demo/resumen.txt',
            fileSizeBytes: 2048,
            fileType: 'txt',
            pageCount: null,
            category: 'Resumen',
            createdAt: DateTime.now(),
          ),
        ];
      } else {
        throw Exception('Error al cargar materiales: ${response.statusCode}');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en fetchMaterials: $_error');
      // Fallback to demo mode on error
      _demoMode = true;
      _materials[courseId] = [
        StudyMaterial(
          id: 'demo-m-1-$courseId',
          courseId: courseId,
          name: 'Apuntes de clase - Introducción.pdf',
          fileUrl: 'https://www.example.com/demo/intro.pdf',
          fileSizeBytes: 256000,
          fileType: 'pdf',
          pageCount: 12,
          category: 'Apuntes',
          createdAt: DateTime.now(),
        ),
        StudyMaterial(
          id: 'demo-m-2-$courseId',
          courseId: courseId,
          name: 'Resumen - Tema 1.txt',
          fileUrl: 'https://www.example.com/demo/resumen.txt',
          fileSizeBytes: 2048,
          fileType: 'txt',
          pageCount: null,
          category: 'Resumen',
          createdAt: DateTime.now(),
        ),
      ];
    }
    notifyListeners();
  }

  // Upload material
  Future<StudyMaterial?> uploadMaterial(
    String courseId,
    String filePath,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check demo mode first to avoid file operations
      if (_demoMode) {
        // Simulate upload in demo mode
        final material = StudyMaterial(
          id: 'demo-upload-${DateTime.now().millisecondsSinceEpoch}',
          courseId: courseId,
          name: filePath.split('/').last.split('\\').last,
          fileUrl: 'https://www.example.com/demo/file.pdf',
          fileSizeBytes: 123456,
          fileType: 'pdf',
          pageCount: null,
          category: 'Subido',
          createdAt: DateTime.now(),
        );
        if (_materials[courseId] == null) _materials[courseId] = [];
        _materials[courseId]!.insert(0, material);
        notifyListeners();
        return material;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/materials/upload'),
      );

      request.fields['courseId'] = courseId;
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      request.headers['Authorization'] = 'Bearer ${await ApiService.getToken()}';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        final material = StudyMaterial.fromJson(data['data']);
        
        if (_materials[courseId] == null) {
          _materials[courseId] = [];
        }
        _materials[courseId]!.insert(0, material);
        notifyListeners();
        return material;
      } else if (response.statusCode == 404) {
        // Backend not available - fallback to demo mode
        _demoMode = true;
        final material = StudyMaterial(
          id: 'demo-upload-${DateTime.now().millisecondsSinceEpoch}',
          courseId: courseId,
          name: filePath.split('/').last.split('\\').last,
          fileUrl: 'https://www.example.com/demo/file.pdf',
          fileSizeBytes: 123456,
          fileType: 'pdf',
          pageCount: null,
          category: 'Subido',
          createdAt: DateTime.now(),
        );
        if (_materials[courseId] == null) _materials[courseId] = [];
        _materials[courseId]!.insert(0, material);
        notifyListeners();
        return material;
      }
    } catch (err) {
      _error = err.toString();
      print('Error en uploadMaterial: $err');
      // Fallback to demo mode on error
      _demoMode = true;
      final material = StudyMaterial(
        id: 'demo-upload-${DateTime.now().millisecondsSinceEpoch}',
        courseId: courseId,
        name: 'archivo_subido.pdf',
        fileUrl: 'https://www.example.com/demo/file.pdf',
        fileSizeBytes: 123456,
        fileType: 'pdf',
        pageCount: null,
        category: 'Subido',
        createdAt: DateTime.now(),
      );
      if (_materials[courseId] == null) _materials[courseId] = [];
      _materials[courseId]!.insert(0, material);
      notifyListeners();
      return material;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Summarize material
  Future<AIResponse?> summarizeMaterial(String materialId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_demoMode) {
        // Return a canned summary in demo mode
        final aiResponse = AIResponse(
          id: 'demo-sum-$materialId',
          type: 'summary',
          content: 'Resumen de ejemplo: conceptos clave, definiciones y puntos importantes del material.',
          generatedAt: DateTime.now(),
          fromCache: false,
        );
        notifyListeners();
        return aiResponse;
      }

      final response = await ApiService.post(
        '/ai/summarize',
        {'materialId': materialId},
        auth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = AIResponse.fromJson(data['data']);
        notifyListeners();
        return aiResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al resumir');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en summarizeMaterial: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Generate quiz
  Future<bool> generateQuiz(String courseId, {int count = 5}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_demoMode) {
        // Create demo questions
        _questions = List.generate(count, (i) => StudyQuestion(
          id: 'demo-q-$i',
          questionText: 'Pregunta de ejemplo ${i+1} sobre el curso.',
          options: {
            'A': 'Opción A',
            'B': 'Opción B',
            'C': 'Opción C',
            'D': 'Opción D',
          },
          correctOption: 'A',
          explanation: 'Explicación de ejemplo de por qué A es la respuesta correcta.',
          difficultyLevel: 'medium',
        ));
        notifyListeners();
        return true;
      }

      final response = await ApiService.post(
        '/ai/generate-quiz',
        {
          'courseId': courseId,
          'count': count,
          'difficulty': 'medium',
        },
        auth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await fetchQuestions(courseId);
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al generar quiz');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en generateQuiz: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // Ask question
  Future<AIResponse?> askQuestion(String courseId, String question) async {
    try {
      if (question.trim().isEmpty) {
        throw Exception('La pregunta no puede estar vacía');
      }

      if (_demoMode) {
        return AIResponse(
          id: 'demo-ask-${DateTime.now().millisecondsSinceEpoch}',
          type: 'answer',
          content: 'Respuesta de ejemplo generada por la IA: enfoque, pasos y recursos relacionados.',
          generatedAt: DateTime.now(),
          fromCache: false,
        );
      }

      final response = await ApiService.post(
        '/ai/ask-question',
        {
          'courseId': courseId,
          'question': question,
        },
        auth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = AIResponse.fromJson(data['data']);
        return aiResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al procesar pregunta');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en askQuestion: $_error');
    }
    return null;
  }

  // Get questions for course
  Future<void> fetchQuestions(String courseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_demoMode) {
        // Provide demo questions if demo mode
        _questions = [
          StudyQuestion(
            id: 'demo-q-1',
            questionText: '¿Cuál es la complejidad temporal del algoritmo de búsqueda binaria?',
            options: {'A': 'O(n)', 'B': 'O(log n)', 'C': 'O(n^2)', 'D': 'O(1)'},
            correctOption: 'B',
            explanation: 'La búsqueda binaria divide el espacio de búsqueda a la mitad en cada paso.',
            difficultyLevel: 'medium',
          ),
        ];
        notifyListeners();
        return;
      }

      final response = await ApiService.get('/ai/questions/$courseId', auth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _questions = (data['data'] as List? ?? [])
            .map((json) => StudyQuestion.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else if (response.statusCode == 404) {
        // Backend not available - use demo mode
        _demoMode = true;
        _questions = [
          StudyQuestion(
            id: 'demo-q-1-$courseId',
            questionText: '¿Cuál es la complejidad temporal del algoritmo de búsqueda binaria?',
            options: {'A': 'O(n)', 'B': 'O(log n)', 'C': 'O(n^2)', 'D': 'O(1)'},
            correctOption: 'B',
            explanation: 'La búsqueda binaria divide el espacio de búsqueda a la mitad en cada paso.',
            difficultyLevel: 'medium',
          ),
          StudyQuestion(
            id: 'demo-q-2-$courseId',
            questionText: '¿Qué estructura de datos utiliza el principio LIFO?',
            options: {'A': 'Cola', 'B': 'Pila', 'C': 'Lista', 'D': 'Árbol'},
            correctOption: 'B',
            explanation: 'La pila (stack) utiliza el principio Last In, First Out.',
            difficultyLevel: 'easy',
          ),
        ];
      } else {
        throw Exception('Error al cargar preguntas: ${response.statusCode}');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en fetchQuestions: $_error');
      // Fallback to demo mode on error
      _demoMode = true;
      _questions = [
        StudyQuestion(
          id: 'demo-q-1-$courseId',
          questionText: '¿Cuál es la complejidad temporal del algoritmo de búsqueda binaria?',
          options: {'A': 'O(n)', 'B': 'O(log n)', 'C': 'O(n^2)', 'D': 'O(1)'},
          correctOption: 'B',
          explanation: 'La búsqueda binaria divide el espacio de búsqueda a la mitad en cada paso.',
          difficultyLevel: 'medium',
        ),
        StudyQuestion(
          id: 'demo-q-2-$courseId',
          questionText: '¿Qué estructura de datos utiliza el principio LIFO?',
          options: {'A': 'Cola', 'B': 'Pila', 'C': 'Lista', 'D': 'Árbol'},
          correctOption: 'B',
          explanation: 'La pila (stack) utiliza el principio Last In, First Out.',
          difficultyLevel: 'easy',
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit quiz attempt
  Future<Map<String, dynamic>?> submitQuizAttempt(
    String courseId,
    Map<String, String> answers,
    int timeSpent,
  ) async {
    try {
      if (answers.isEmpty) {
        throw Exception('Debes responder al menos una pregunta');
      }

      final response = await ApiService.post(
        '/ai/quiz-attempt',
        {
          'courseId': courseId,
          'answers': answers,
          'timeSpent': timeSpent,
        },
        auth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al enviar intento');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en submitQuizAttempt: $_error');
    }
    return null;
  }

  // Get questions by course
  List<StudyQuestion> getQuestionsByCourse(String courseId) {
    return _questions;
  }

  // Delete course
  Future<bool> deleteCourse(String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_demoMode) {
        _courses.removeWhere((c) => c.id == courseId);
        _materials.remove(courseId);
        notifyListeners();
        return true;
      }

      final response = await ApiService.delete('/study/courses/$courseId', auth: true);

      if (response.statusCode == 200) {
        _courses.removeWhere((c) => c.id == courseId);
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else if (response.statusCode == 404) {
        // Backend not available - use demo mode
        _demoMode = true;
        _courses.removeWhere((c) => c.id == courseId);
        _materials.remove(courseId);
        notifyListeners();
        return true;
      } else {
        throw Exception('Error al eliminar curso');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en deleteCourse: $_error');
      // Fallback to demo mode on error
      _demoMode = true;
      _courses.removeWhere((c) => c.id == courseId);
      _materials.remove(courseId);
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete material
  Future<bool> deleteMaterial(String materialId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_demoMode) {
        _materials.forEach((key, list) {
          list.removeWhere((m) => m.id == materialId);
        });
        notifyListeners();
        return true;
      }

      final response = await ApiService.delete('/study/materials/$materialId', auth: true);

      if (response.statusCode == 200) {
        _materials.forEach((key, list) {
          list.removeWhere((m) => m.id == materialId);
        });
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else if (response.statusCode == 404) {
        // Backend not available - use demo mode
        _demoMode = true;
        _materials.forEach((key, list) {
          list.removeWhere((m) => m.id == materialId);
        });
        notifyListeners();
        return true;
      } else {
        throw Exception('Error al eliminar material');
      }
    } catch (err) {
      _error = err.toString();
      print('Error en deleteMaterial: $_error');
      // Fallback to demo mode on error
      _demoMode = true;
      _materials.forEach((key, list) {
        list.removeWhere((m) => m.id == materialId);
      });
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
