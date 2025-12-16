import 'package:aptcoder/models/course_model.dart';
import 'package:aptcoder/providers/auth_provider.dart';
import 'package:aptcoder/providers/course_provider.dart';
import 'package:aptcoder/providers/user_provider.dart';
import 'package:aptcoder/screens/student/course_detail_screen.dart';
import 'package:aptcoder/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_animate/flutter_animate.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return RefreshIndicator(
      onRefresh: () => userProvider.fetchAllUsers(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'User Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ).animate().fade().slideX(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Users',
                  value: userProvider.allUsers.length.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Students',
                  value: userProvider.allUsers
                      .where((u) => u.role == 'student')
                      .length
                      .toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ).animate().fade(delay: 200.ms).slideX(),
          const SizedBox(height: 20),
          if (userProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userProvider.allUsers.length,
              itemBuilder: (context, index) {
                final user = userProvider.allUsers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrl.isNotEmpty
                          ? NetworkImage(user.photoUrl)
                          : null,
                      child: user.photoUrl.isEmpty
                          ? Text(user.displayName[0].toUpperCase())
                          : null,
                    ),
                    title: Text(user.displayName),
                    subtitle: Text(
                      '${user.email}\n${user.role.toUpperCase()} • ${user.totalPoints} points',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Make Admin'),
                          onTap: () async {
                            await authProvider.updateUserRole(
                              user.uid,
                              'admin',
                            );
                            await userProvider.fetchAllUsers();
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Make Student'),
                          onTap: () async {
                            await authProvider.updateUserRole(
                              user.uid,
                              'student',
                            );
                            await userProvider.fetchAllUsers();
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: (300 + (index * 100)).ms).slideY(
                  begin: 0.2,
                  end: 0,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final user = authProvider.currentUser;

    final enrolledCourses = courseProvider.courses
        .where((course) => user?.enrolledCourses.contains(course.id) ?? false)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Learning Journey',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (enrolledCourses.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.book_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses enrolled yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start learning by enrolling in a course',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: enrolledCourses.length,
              itemBuilder: (context, index) {
                final course = enrolledCourses[index];
                final progress = user?.courseProgress[course.id] ?? 0;
                return _EnrolledCourseCard(course: course, progress: progress);
              },
            ),
        ],
      ),
    );
  }
}

class _EnrolledCourseCard extends StatelessWidget {
  final CourseModel course;
  final int progress;

  const _EnrolledCourseCard({required this.course, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.book,
                      color: AppTheme.primaryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.totalLessons} lessons • ${course.difficulty}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$progress%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
