import 'package:aptcoder/models/course_model.dart';
import 'package:aptcoder/utils/seed_data.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all courses
  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore.collection('courses').get();

      if (snapshot.docs.isEmpty) {
        // Auto-seed if empty
        await SeedData.seedCourses();
        snapshot = await _firestore.collection('courses').get();
      } else {
        print('Found ${snapshot.docs.length} courses.');
      }

      _courses = snapshot.docs
          .map(
            (doc) =>
                CourseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch courses: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new course (admin)
  Future<bool> addCourse(CourseModel course) async {
    try {
      await _firestore.collection('courses').add(course.toMap());
      await fetchCourses();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add course: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update course
  Future<bool> updateCourse(String courseId, CourseModel course) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .update(course.toMap());
      await fetchCourses();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update course: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Delete course
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
      await fetchCourses();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete course: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Enroll student in course
  Future<bool> enrollCourse(String userId, String courseId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
      });

      await _firestore.collection('courses').doc(courseId).update({
        'enrolledStudents': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to enroll: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update course progress
  Future<void> updateProgress(
    String userId,
    String courseId,
    int progress,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'courseProgress.$courseId': progress,
      });
    } catch (e) {
      _errorMessage = 'Failed to update progress: ${e.toString()}';
    }
  }
}
