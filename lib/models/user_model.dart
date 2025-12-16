class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String role; // 'admin' or 'student'
  final DateTime createdAt;
  final int totalPoints;
  final List<String> enrolledCourses;
  final Map<String, int> courseProgress;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    required this.role,
    required this.createdAt,
    this.totalPoints = 0,
    this.enrolledCourses = const [],
    this.courseProgress = const {},
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: DateTime.parse(map['createdAt']),
      totalPoints: map['totalPoints'] ?? 0,
      enrolledCourses: List<String>.from(map['enrolledCourses'] ?? []),
      courseProgress: Map<String, int>.from(map['courseProgress'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'totalPoints': totalPoints,
      'enrolledCourses': enrolledCourses,
      'courseProgress': courseProgress,
    };
  }
}
