// lib/models/study_models.dart

class StudyCourse {
  final String id;
  final String name;
  final String? courseCode;
  final String? professorName;
  final String? description;
  final int? semester;
  final int? year;
  final bool isArchived;
  final DateTime createdAt;
  final int? materialCount;
  final int? questionCount;

  StudyCourse({
    required this.id,
    required this.name,
    this.courseCode,
    this.professorName,
    this.description,
    this.semester,
    this.year,
    this.isArchived = false,
    required this.createdAt,
    this.materialCount,
    this.questionCount,
  });

  factory StudyCourse.fromJson(Map<String, dynamic> json) {
    return StudyCourse(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      courseCode: json['course_code'],
      professorName: json['professor_name'],
      description: json['description'],
      semester: json['semester'],
      year: json['year'],
      isArchived: json['is_archived'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      materialCount: json['material_count'],
      questionCount: json['question_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'course_code': courseCode,
      'professor_name': professorName,
      'description': description,
      'semester': semester,
      'year': year,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class StudyMaterial {
  final String id;
  final String courseId;
  final String name;
  final String fileUrl;
  final int? fileSizeBytes;
  final String fileType;
  final int? pageCount;
  final String? category;
  final DateTime createdAt;

  StudyMaterial({
    required this.id,
    required this.courseId,
    required this.name,
    required this.fileUrl,
    this.fileSizeBytes,
    required this.fileType,
    this.pageCount,
    this.category,
    required this.createdAt,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      fileUrl: json['file_url'] ?? '',
      fileSizeBytes: json['file_size_bytes'],
      fileType: json['file_type'] ?? 'document',
      pageCount: json['page_count'],
      category: json['category'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get formattedSize {
    if (fileSizeBytes == null) return 'N/A';
    final mb = fileSizeBytes! / (1024 * 1024);
    return mb < 1 ? '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB' : '${mb.toStringAsFixed(1)} MB';
  }
}

class AIResponse {
  final String id;
  final String type;
  final String content;
  final DateTime generatedAt;
  final bool fromCache;

  AIResponse({
    required this.id,
    required this.type,
    required this.content,
    required this.generatedAt,
    this.fromCache = false,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      id: json['id'] ?? '',
      type: json['type'] ?? json['response_type'] ?? 'unknown',
      content: json['content'] ?? json['response_content'] ?? '',
      generatedAt: DateTime.tryParse(json['generatedAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      fromCache: json['fromCache'] ?? false,
    );
  }
}

class StudyQuestion {
  final String id;
  final String questionText;
  final Map<String, String> options;
  final String correctOption;
  final String explanation;
  final String difficultyLevel;

  StudyQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOption,
    required this.explanation,
    required this.difficultyLevel,
  });

  factory StudyQuestion.fromJson(Map<String, dynamic> json) {
    return StudyQuestion(
      id: json['id'] ?? '',
      questionText: json['question_text'] ?? '',
      options: Map<String, String>.from(json['options'] ?? {}),
      correctOption: json['correct_option'] ?? '',
      explanation: json['explanation'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? 'medium',
    );
  }
}
