class CourseModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String category;
  final int totalLessons;
  final int duration; // in minutes
  final String difficulty;
  final List<LessonModel> lessons;
  final DateTime createdAt;
  final int enrolledStudents;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.category,
    required this.totalLessons,
    required this.duration,
    required this.difficulty,
    required this.lessons,
    required this.createdAt,
    this.enrolledStudents = 0,
  });

  factory CourseModel.fromMap(String id, Map<String, dynamic> map) {
    return CourseModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      category: map['category'] ?? '',
      totalLessons: map['totalLessons'] ?? 0,
      duration: map['duration'] ?? 0,
      difficulty: map['difficulty'] ?? 'Beginner',
      lessons:
          (map['lessons'] as List<dynamic>?)
              ?.map((l) => LessonModel.fromMap(l))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
      enrolledStudents: map['enrolledStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'totalLessons': totalLessons,
      'duration': duration,
      'difficulty': difficulty,
      'lessons': lessons.map((l) => l.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'enrolledStudents': enrolledStudents,
    };
  }
}

class LessonModel {
  final String id;
  final String title;
  final String type; // 'video', 'pdf', 'ppt', 'mcq'
  final String contentUrl;
  final int duration;
  final List<MCQModel>? mcqs;

  LessonModel({
    required this.id,
    required this.title,
    required this.type,
    required this.contentUrl,
    required this.duration,
    this.mcqs,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      contentUrl: map['contentUrl'] ?? '',
      duration: map['duration'] ?? 0,
      mcqs: map['mcqs'] != null
          ? (map['mcqs'] as List).map((m) => MCQModel.fromMap(m)).toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'contentUrl': contentUrl,
      'duration': duration,
      'mcqs': mcqs?.map((m) => m.toMap()).toList(),
    };
  }
}

class MCQModel {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  MCQModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory MCQModel.fromMap(Map<String, dynamic> map) {
    return MCQModel(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      explanation: map['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}
