import 'package:aptcoder/models/course_model.dart';
import 'package:aptcoder/providers/auth_provider.dart';
import 'package:aptcoder/providers/course_provider.dart';
import 'package:aptcoder/providers/user_provider.dart';
import 'package:aptcoder/utils/seed_data.dart';
import 'package:aptcoder/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_course_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
      Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final List<Widget> _screens = [
      _DashboardHome(),
      _CoursesManagement(),
      ManageUsersScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Seed Database',
            onPressed: () async {
              final courseProvider = Provider.of<CourseProvider>(context, listen: false);
              final hasCourses = courseProvider.courses.isNotEmpty;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(hasCourses ? 'Re-seed Database?' : 'Seed Database'),
                  content: Text(
                    hasCourses 
                        ? 'This will DELETE ALL existing courses and replace them with sample data. This relies on stable image URLs. Continue?'
                        : 'This will add sample courses to the database. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: hasCourses ? TextButton.styleFrom(foregroundColor: Colors.red) : null,
                      child: Text(hasCourses ? 'Overwrite' : 'Seed'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // Show loading indicator
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seeding database... Please wait')),
                  );
                }
                
                await SeedData.seedCourses(force: hasCourses);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database seeded successfully!')),
                  );
                  Provider.of<CourseProvider>(context, listen: false).fetchCourses();
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final totalCourses = courseProvider.courses.length;
    final totalStudents = userProvider.allUsers
        .where((u) => u.role == 'student')
        .length;
    final totalEnrollments = courseProvider.courses.fold(
      0,
      (sum, c) => sum + c.enrolledStudents,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.book,
                title: 'Total Courses',
                value: totalCourses.toString(),
                color: Colors.blue,
              ),
              _StatCard(
                icon: Icons.people,
                title: 'Total Students',
                value: totalStudents.toString(),
                color: Colors.green,
              ),
              _StatCard(
                icon: Icons.school,
                title: 'Total Enrollments',
                value: totalEnrollments.toString(),
                color: Colors.orange,
              ),
              _StatCard(
                icon: Icons.trending_up,
                title: 'Active Users',
                value: userProvider.allUsers.length.toString(),
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Courses',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (courseProvider.courses.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('No courses yet. Add your first course!'),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courseProvider.courses.take(5).length,
              itemBuilder: (context, index) {
                final course = courseProvider.courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(course.title),
                    subtitle: Text('${course.enrolledStudents} enrolled'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Categories Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _buildCategoryChart(courseProvider.courses),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(List<CourseModel> courses) {
    if (courses.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    Map<String, int> categoryCount = {};
    for (var course in courses) {
      categoryCount[course.category] =
          (categoryCount[course.category] ?? 0) + 1;
    }

    List<PieChartSectionData> sections = [];
    int index = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    categoryCount.forEach((category, count) {
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: count.toDouble(),
          title: '$category\n$count',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return PieChart(
      PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 40),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoursesManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Courses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCourseScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Course'),
              ),
            ],
          ),
        ),
        Expanded(
          child: courseProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : courseProvider.courses.isEmpty
              ? const Center(child: Text('No courses yet'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courseProvider.courses.length,
                  itemBuilder: (context, index) {
                    final course = courseProvider.courses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.1,
                          ),
                          child: const Icon(
                            Icons.book,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(course.title),
                        subtitle: Text(
                          '${course.totalLessons} lessons • ${course.enrolledStudents} enrolled',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course.description),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Course'),
                                            content: const Text(
                                              'Are you sure?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await courseProvider.deleteCourse(
                                            course.id,
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
