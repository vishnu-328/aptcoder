import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import '../../utils/theme.dart';

import 'package:flutter_animate/flutter_animate.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({Key? key}) : super(key: key);

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  String _selectedCategory = 'Programming';
  String _selectedDifficulty = 'Beginner';
  final List<LessonModel> _lessons = [];

  final List<String> categories = [
    'Programming',
    'Web Development',
    'Mobile Development',
    'AI/ML',
    'Vedic Mathematics',
    'IoT',
  ];

  final List<String> difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _addLesson() {
    showDialog(
      context: context,
      builder: (context) => _LessonDialog(
        onSave: (lesson) {
          setState(() => _lessons.add(lesson));
        },
      ),
    );
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one lesson')),
      );
      return;
    }

    final course = CourseModel(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      thumbnailUrl: _thumbnailController.text,
      category: _selectedCategory,
      totalLessons: _lessons.length,
      duration: _lessons.fold(0, (sum, l) => sum + l.duration),
      difficulty: _selectedDifficulty,
      lessons: _lessons,
      createdAt: DateTime.now(),
    );

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    bool success = await courseProvider.addCourse(course);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Course'),
        actions: [
          TextButton(
            onPressed: _saveCourse,
            child: const Text(
              'SAVE',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ).animate().fade().slideX(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ).animate().fade(delay: 100.ms).slideX(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thumbnailController,
              decoration: const InputDecoration(
                labelText: 'Thumbnail URL',
                prefixIcon: Icon(Icons.image),
              ),
            ).animate().fade(delay: 200.ms).slideX(),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ).animate().fade(delay: 300.ms).slideX(),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                prefixIcon: Icon(Icons.signal_cellular_alt),
              ),
              items: difficulties
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedDifficulty = value!),
            ).animate().fade(delay: 400.ms).slideX(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lessons (${_lessons.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addLesson,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Lesson'),
                ),
              ],
            ).animate().fade(delay: 500.ms),
            const SizedBox(height: 12),
            if (_lessons.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No lessons added yet')),
                ),
              ).animate().fade(delay: 600.ms)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  final lesson = _lessons[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(lesson.title),
                      subtitle: Text(
                        '${lesson.type.toUpperCase()} • ${lesson.duration} min',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() => _lessons.removeAt(index));
                        },
                      ),
                    ),
                  ).animate().fade(delay: (600 + (index * 100)).ms).slideX();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LessonDialog extends StatefulWidget {
  final Function(LessonModel) onSave;

  const _LessonDialog({required this.onSave});

  @override
  State<_LessonDialog> createState() => _LessonDialogState();
}

class _LessonDialogState extends State<_LessonDialog> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedType = 'video';

  final List<String> lessonTypes = ['video', 'pdf', 'ppt', 'mcq'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Lesson'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Lesson Title'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: lessonTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: _selectedType == 'mcq'
                    ? 'MCQ Data (JSON)'
                    : 'Content URL',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _urlController.text.isNotEmpty) {
              final lesson = LessonModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text,
                type: _selectedType,
                contentUrl: _urlController.text,
                duration: int.tryParse(_durationController.text) ?? 10,
              );
              widget.onSave(lesson);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
