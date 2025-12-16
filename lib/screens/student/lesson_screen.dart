import 'package:aptcoder/models/course_model.dart';
import 'package:aptcoder/utils/theme.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class LessonScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  int _score = 0;

  // Video Player Controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.type == 'video') {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.lesson.contentUrl),
    );
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          if (widget.lesson.type != 'mcq' && widget.lesson.type != 'video' && widget.lesson.type != 'pdf')
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _launchURL(widget.lesson.contentUrl),
            ),
        ],
      ),
      body: _buildLessonContent(),
    );
  }

  Widget _buildLessonContent() {
    switch (widget.lesson.type) {
      case 'video':
        return _buildVideoPlayer();
      case 'pdf':
        return _buildPDFViewer();
      case 'ppt':
        return _buildPPTViewer();
      case 'mcq':
        return _buildMCQQuiz();
      default:
        return const Center(child: Text('Content type not supported'));
    }
  }

  Widget _buildVideoPlayer() {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildPDFViewer() {
    return SfPdfViewer.network(
      widget.lesson.contentUrl,
      canShowScrollHead: false,
      canShowScrollStatus: false,
    );
  }

  Widget _buildPPTViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.slideshow, size: 100, color: Colors.orange),
          const SizedBox(height: 20),
          const Text('PowerPoint Presentation', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Presentations are best viewed in their native application.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _launchURL(widget.lesson.contentUrl),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Open Presentation'),
          ),
        ],
      ),
    );
  }

  Widget _buildMCQQuiz() {
    if (widget.lesson.mcqs == null || widget.lesson.mcqs!.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    if (_currentQuestionIndex >= widget.lesson.mcqs!.length) {
      return _buildQuizResult();
    }

    final question = widget.lesson.mcqs![_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.lesson.mcqs!.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Question ${_currentQuestionIndex + 1}/${widget.lesson.mcqs!.length}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: _showResult
                    ? null
                    : () {
                        setState(() => _selectedAnswer = index);
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getOptionColor(index, question.correctAnswer),
                    border: Border.all(
                      color: _selectedAnswer == index
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      width: _selectedAnswer == index ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _selectedAnswer == index
                            ? AppTheme.primaryColor
                            : Colors.grey.shade200,
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: _selectedAnswer == index
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (_showResult && index == question.correctAnswer)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_showResult && question.explanation.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAnswer == null ? null : _handleNextQuestion,
              child: Text(_showResult ? 'Next Question' : 'Submit Answer'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getOptionColor(int index, int correctAnswer) {
    if (!_showResult) return Colors.transparent;
    if (index == correctAnswer) return Colors.green.shade50;
    if (index == _selectedAnswer && _selectedAnswer != correctAnswer) {
      return Colors.red.shade50;
    }
    return Colors.transparent;
  }

  void _handleNextQuestion() {
    if (!_showResult) {
      setState(() {
        _showResult = true;
        if (_selectedAnswer ==
            widget.lesson.mcqs![_currentQuestionIndex].correctAnswer) {
          _score++;
        }
      });
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    }
  }

  Widget _buildQuizResult() {
    final percentage = (_score / widget.lesson.mcqs!.length * 100).toInt();
    final isPassed = percentage >= 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPassed ? Icons.celebration : Icons.replay,
              size: 100,
              color: isPassed ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              isPassed ? 'Congratulations!' : 'Keep Learning!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'You scored $_score out of ${widget.lesson.mcqs!.length}',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex = 0;
                    _selectedAnswer = null;
                    _showResult = false;
                    _score = 0;
                  });
                },
                child: const Text('Retake Quiz'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Course'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }
}
