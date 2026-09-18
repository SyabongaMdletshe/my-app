import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../theme/app_theme.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String type;
  const QuizScreen({super.key, required this.type});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _current = 0;
  Map<int, String> _answers = {};
  Map<String, int> _tags = {};
  bool _loading = true;
  bool _saving = false;

  bool get _isJobFit => widget.type == 'job_fit';

  Color get _themeColor =>
      _isJobFit ? const Color(0xFF00695C) : const Color(0xFF3949AB);

  IconData get _themeIcon =>
      _isJobFit ? Icons.badge_outlined : Icons.psychology_outlined;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final data = await SupabaseService.client
        .from('questions')
        .select()
        .eq('type', widget.type)
        .order('order_index');

    setState(() {
      _questions = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  void _selectOption(String label, List tags) {
    final q = _questions[_current];
    _answers[q['id']] = label;
    for (final t in tags) {
      _tags[t.toString()] = (_tags[t.toString()] ?? 0) + 1;
    }
    if (_current < _questions.length - 1) {
      setState(() => _current++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    try {
      final answersSafe =
          _answers.map((k, v) => MapEntry(k.toString(), v));
      await SupabaseService.client.from('journeys').insert({
        'user_id': AuthService.currentUser?.id,
        'data': {
          'type': widget.type,
          'answers': answersSafe,
          'tags': _tags,
        },
      });
    } catch (e) {
      debugPrint('Save failed: $e');
    }

    final ranked = await _rankCareers();

    if (!mounted) return;
    setState(() => _saving = false);

    if (ranked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No career matches found.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          quizType: widget.type,
          ranked: ranked,
        ),
      ),
    );
  }

  Future<List<MapEntry<Map<String, dynamic>, int>>> _rankCareers() async {
    final careers = await CacheService.fetchList('careers', orderBy: 'title');
    final scored = <MapEntry<Map<String, dynamic>, int>>[];

    for (final c in careers) {
      final careerTags =
          (c['subjects'] as List?)?.cast<String>() ?? <String>[];
      int matches = 0;
      for (final t in _tags.keys) {
        for (final subj in careerTags) {
          if (subj.toLowerCase().contains(t.toLowerCase()) ||
              t.toLowerCase().contains(subj.toLowerCase())) {
            matches += _tags[t]!;
          }
        }
      }

      final title = (c['title'] ?? '').toString().toLowerCase();
      if (_tags['tech'] != null &&
          (title.contains('software') ||
              title.contains('data') ||
              title.contains('engineer') ||
              title.contains('network') ||
              title.contains('it'))) {
        matches += _tags['tech']! * 2;
      }
      if (_tags['health'] != null &&
          (title.contains('nurse') ||
              title.contains('doctor') ||
              title.contains('pharm') ||
              title.contains('physio') ||
              title.contains('diet'))) {
        matches += _tags['health']! * 2;
      }
      if (_tags['business'] != null &&
          (title.contains('account') ||
              title.contains('financ') ||
              title.contains('market') ||
              title.contains('hr') ||
              title.contains('entre'))) {
        matches += _tags['business']! * 2;
      }
      if (_tags['creative'] != null &&
          (title.contains('design') ||
              title.contains('art') ||
              title.contains('film') ||
              title.contains('fashion'))) {
        matches += _tags['creative']! * 2;
      }
      if (_tags['engineering'] != null &&
          (title.contains('engineer') ||
              title.contains('electric') ||
              title.contains('plumb') ||
              title.contains('weld'))) {
        matches += _tags['engineering']! * 2;
      }

      if (matches > 0) scored.add(MapEntry(c, matches));
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    final top = scored.take(10).toList();
    if (top.isEmpty) return [];

    final maxScore = top.first.value;
    final results = <MapEntry<Map<String, dynamic>, int>>[];

    for (int i = 0; i < top.length; i++) {
      final raw = (top[i].value / maxScore) * 100;
      int pct = (raw * 0.92).round();
      if (i > 0 && pct >= results[i - 1].value) {
        pct = results[i - 1].value - 3;
      }
      if (pct < 20) pct = 20;
      results.add(MapEntry(top[i].key, pct));
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('No questions yet.')));
    }

    final q = _questions[_current];
    final options = List<Map<String, dynamic>>.from(q['options']);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isJobFit ? 'Job Fit Questionnaire' : 'Career Choice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_themeIcon, color: _themeColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_current + 1) / _questions.length,
                    backgroundColor: _themeColor.withValues(alpha: 0.1),
                    color: _themeColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${_current + 1}/${_questions.length}',
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 28),
            Text(q['question'],
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final opt = options[i];
                  final selected = _answers[q['id']] == opt['label'];
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () =>
                        _selectOption(opt['label'], opt['tags'] ?? []),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected
                            ? _themeColor.withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? _themeColor
                              : Colors.grey.withValues(alpha: 0.35),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(opt['label'],
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ),
                          if (selected)
                            Icon(Icons.check_circle, color: _themeColor),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_current > 0)
              TextButton.icon(
                onPressed: () => setState(() => _current--),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous question'),
              ),
            if (_saving)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}