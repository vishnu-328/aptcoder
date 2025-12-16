import 'package:aptcoder/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundImage: user?.photoUrl.isNotEmpty == true
                ? NetworkImage(user!.photoUrl)
                : null,
            child: user?.photoUrl.isEmpty == true
                ? Text(
                    user?.displayName[0].toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 40),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Student',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Achievement Cards
          Row(
            children: [
              Expanded(
                child: _AchievementCard(
                  icon: Icons.emoji_events,
                  title: 'Total Points',
                  value: user?.totalPoints.toString() ?? '0',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AchievementCard(
                  icon: Icons.book,
                  title: 'Courses',
                  value: user?.enrolledCourses.length.toString() ?? '0',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AchievementCard(
                  icon: Icons.star,
                  title: 'Rank',
                  value: '#--',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AchievementCard(
                  icon: Icons.local_fire_department,
                  title: 'Streak',
                  value: '0 days',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Profile Options
          Card(
            child: Column(
              children: [
                _ProfileOption(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _ProfileOption(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _ProfileOption(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _ProfileOption(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _ProfileOption(
                  icon: Icons.info_outline,
                  title: 'About APTCODER',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AboutDialog(
                        applicationName: 'APTCODER',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            '© 2024 SNN Eduworld Pvt. Ltd.\nIncubated at IIM Lucknow\nStartup India Initiative',
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _ProfileOption(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () async {
                    await authProvider.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  textColor: Colors.red,
                ),
                const Divider(height: 1),
                // Debug Option
                _ProfileOption(
                  icon: Icons.developer_mode,
                  title: 'Switch Role (Debug)',
                  onTap: () async {
                    final newRole = user?.role == 'admin' ? 'student' : 'admin';
                    await authProvider.updateUserRole(user!.uid, newRole);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Switched to $newRole')),
                    );
                    if (newRole == 'admin') {
                      Navigator.pushReplacementNamed(context, '/admin');
                    } else {
                      Navigator.pushReplacementNamed(context, '/student');
                    }
                  },
                  textColor: Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _AchievementCard({
    required this.icon,
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
