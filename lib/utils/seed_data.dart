import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class SeedData {
  static Future<void> seedCourses({bool force = false}) async {
    final firestore = FirebaseFirestore.instance;
    final coursesCollection = firestore.collection('courses');

    // Check if courses already exist
    final snapshot = await coursesCollection.get();
    if (snapshot.docs.isNotEmpty) {
      if (!force) {
        print('Database already seeded.');
        return;
      }
      // If force is true, delete existing courses
      print('Force seeding: Deleting existing courses...');
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    print('Seeding database with sample courses...');

    final List<CourseModel> sampleCourses = [
      CourseModel(
        id: '', // Will be set by Firestore
        title: 'Flutter for Beginners',
        description:
            'Learn the basics of Flutter and build your first mobile application. This course covers widgets, state management, and navigation.',
        thumbnailUrl:
            'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png',
        category: 'Mobile Development',
        totalLessons: 3,
        duration: 45,
        difficulty: 'Beginner',
        lessons: [
          LessonModel(
            id: 'l1',
            title: 'Introduction to Flutter',
            type: 'video',
            contentUrl:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', // Sample video
            duration: 10,
          ),
          LessonModel(
            id: 'l2',
            title: 'Flutter Widgets PDF',
            type: 'pdf',
            contentUrl:
                'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', // Sample PDF
            duration: 15,
          ),
          LessonModel(
            id: 'l3',
            title: 'Flutter Basics Quiz',
            type: 'mcq',
            contentUrl: '',
            duration: 20,
            mcqs: [
              MCQModel(
                question: 'What language is Flutter built with?',
                options: ['Java', 'Kotlin', 'Dart', 'Swift'],
                correctAnswer: 2,
                explanation:
                    'Flutter uses Dart programming language developed by Google.',
              ),
              MCQModel(
                question: 'Who developed Flutter?',
                options: ['Facebook', 'Google', 'Microsoft', 'Apple'],
                correctAnswer: 1,
                explanation: 'Flutter is an open-source UI toolkit by Google.',
              ),
            ],
          ),
        ],
        createdAt: DateTime.now(),
      ),
      CourseModel(
        id: '',
        title: 'Advanced Python',
        description:
            'Master Python with advanced concepts like decorators, generators, and context managers.',
        thumbnailUrl:
            "https://www.citypng.com/public/uploads/preview/hd-python-logo-symbol-transparent-png-735811696257415dbkifcuokn.png",
        category: 'Programming',
        totalLessons: 2,
        duration: 60,
        difficulty: 'Advanced',
        lessons: [
          LessonModel(
            id: 'p1',
            title: 'Decorators Explained',
            type: 'video',
            contentUrl:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            duration: 30,
          ),
          LessonModel(
            id: 'p2',
            title: 'Python Quiz',
            type: 'mcq',
            contentUrl: '',
            duration: 30,
            mcqs: [
              MCQModel(
                question: 'What is a decorator in Python?',
                options: [
                  'A design pattern',
                  'A function that takes another function',
                  'A variable',
                  'A class',
                ],
                correctAnswer: 1,
                explanation:
                    'A decorator is a function that takes another function and extends the behavior of the latter function without explicitly modifying it.',
              ),
            ],
          ),
        ],
        createdAt: DateTime.now(),
      ),
      CourseModel(
        id: '',
        title: 'Vedic Mathematics',
        description:
            'Learn ancient Indian mathematics tricks to solve complex problems in seconds.',
        thumbnailUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Taj_Mahal%2C_Agra%2C_India.jpg/800px-Taj_Mahal%2C_Agra%2C_India.jpg', // More reliable JPG
        category: 'Vedic Mathematics',
        totalLessons: 1,
        duration: 25,
        difficulty: 'Beginner',
        lessons: [
          LessonModel(
            id: 'v1',
            title: 'Sutra 1: Ekadhikena Purvena',
            type: 'pdf',
            contentUrl:
                'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            duration: 25,
          ),
        ],
        createdAt: DateTime.now(),
      ),
    ];

    for (var course in sampleCourses) {
      final docRef = coursesCollection.doc();
      // Create a new map from the course but with the new ID
      final courseData = course.toMap();
      // We don't need to put ID in the map if we use docRef.id separately,
      // but our model might expect it.
      // The CourseModel.fromMap uses the document ID passed to it, so we are good.
      await docRef.set(courseData);
    }
  }
}
