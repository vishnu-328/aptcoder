import 'package:aptcoder/models/course_model.dart';
import 'package:aptcoder/providers/auth_provider.dart';
import 'package:aptcoder/providers/course_provider.dart';
import 'package:aptcoder/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'lesson_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final user = authProvider.currentUser;
    final isEnrolled = user?.enrolledCourses.contains(course.id) ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animate().fade().scale(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.schedule,
                        label: '${course.duration} min',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.video_library,
                        label: '${course.totalLessons} lessons',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.signal_cellular_alt,
                        label: course.difficulty,
                      ),
                    ],
                  ).animate().fade(delay: 200.ms).slideX(),
                  const SizedBox(height: 20),

                  const Text(
                    'About this course',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ).animate().fade(delay: 300.ms),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ).animate().fade(delay: 400.ms),
                  const SizedBox(height: 24),
                  if (!isEnrolled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool success = await courseProvider.enrollCourse(
                            user!.uid,
                            course.id,
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Successfully enrolled!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Enroll Now - Free',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 500.ms).scale(),
                  const SizedBox(height: 24),
                  const Text(
                    'Course Content',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ).animate().fade(delay: 600.ms),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: course.lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = course.lessons[index];
                      return LessonTile(
                            lesson: lesson,
                            index: index + 1,
                            isLocked: !isEnrolled,
                          )
                          .animate(delay: (600 + (index * 100)).ms)
                          .fade()
                          .slideY(begin: 0.2, end: 0);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final bool isLocked;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.index,
    required this.isLocked,
  });

  IconData _getIcon() {
    switch (lesson.type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'ppt':
        return Icons.slideshow;
      case 'mcq':
        return Icons.quiz;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: isLocked
              ? const Icon(Icons.lock, color: Colors.grey)
              : Icon(_getIcon(), color: AppTheme.primaryColor),
        ),
        title: Text('Lesson $index: ${lesson.title}'),
        subtitle: Text('${lesson.duration} min • ${lesson.type.toUpperCase()}'),
        trailing: isLocked
            ? const Icon(Icons.lock, color: Colors.grey)
            : const Icon(Icons.chevron_right),
        onTap: isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(lesson: lesson),
                  ),
                );
              },
      ),
    );
  }
}
