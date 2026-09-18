import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/cache_service.dart';
import 'career_detail_screen.dart';
import 'qualification_detail_screen.dart';

class SubjectChooserScreen extends StatefulWidget {
  const SubjectChooserScreen({super.key});

  @override
  State<SubjectChooserScreen> createState() => _SubjectChooserScreenState();
}

class _SubjectChooserScreenState extends State<SubjectChooserScreen> {
  static const _subjects = [
    'Mathematics',
    'Physical Sciences',
    'Life Sciences',
    'English',
    'Information Technology',
    'Accounting',
    'Visual Arts',
    'Geography',
    'Statistics',
    'Technical Drawing',
    'Business Studies',
  ];

  final Set<String> _selected = {};
  List<Map<String, dynamic>> _careers = [];
  List<Map<String, dynamic>> _qualifications = [];
  bool _loading = true;
  bool _careersExpanded = false;
  bool _qualsExpanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      CacheService.fetchList('careers', orderBy: 'title'),
      CacheService.fetchList('qualifications', orderBy: 'name'),
    ]);
    if (!mounted) return;
    setState(() {
      _careers = results[0];
      _qualifications = results[1];
      _loading = false;
    });
  }

  void _toggle(String subject) {
    setState(() {
      if (_selected.contains(subject)) {
        _selected.remove(subject);
      } else {
        _selected.add(subject);
      }
    });
  }

  List<Map<String, dynamic>> get _matchingCareers {
    if (_selected.isEmpty) return [];
    return _careers.where((c) {
      final subs = (c['subjects'] as List?)?.cast<String>() ?? [];
      return subs.any((s) => _selected.contains(s));
    }).toList();
  }

  List<Map<String, dynamic>> get _matchingQualifications {
    if (_selected.isEmpty) return [];
    final matchedCareerTitles =
        _matchingCareers.map((c) => c['title'].toString()).toSet();

    return _qualifications.where((q) {
      // 1. match by careers array
      final careers = (q['careers'] as List?)?.cast<String>() ?? [];
      if (careers.any(matchedCareerTitles.contains)) return true;

      // 2. match by requirements text
      final req = (q['requirements'] ?? '').toString().toLowerCase();
      if (_selected.any((s) => req.contains(s.toLowerCase()))) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final careers = _matchingCareers;
    final quals = _matchingQualifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Subject Chooser')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- HEADER ----------
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school,
                          size: 42, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('Pick your subjects',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Select the subjects you want to take and we will show careers and studies that match.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---------- SUBJECTS GRID ----------
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text('Your subjects',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5)),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _subjects.map((s) => _subjectChip(s)).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ---------- ACTION BAR ----------
                  Row(
                    children: [
                      if (_selected.isNotEmpty)
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _selected.clear()),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Clear all'),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.textMuted),
                        ),
                      const Spacer(),
                      if (_selected.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_selected.length} selected',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---------- RESULTS ----------
                  if (_selected.isEmpty)
                    _emptyHint()
                  else ...[
                    _expandablePanel(
                      icon: Icons.work_outline,
                      color: const Color(0xFF00695C),
                      title: 'Careers that fit',
                      count: careers.length,
                      expanded: _careersExpanded,
                      onToggle: () => setState(
                          () => _careersExpanded = !_careersExpanded),
                      children: careers
                          .map((c) => _careerTile(c))
                          .toList(),
                      emptyMessage:
                          'No careers match these subjects yet.',
                    ),
                    const SizedBox(height: 12),
                    _expandablePanel(
                      icon: Icons.menu_book_outlined,
                      color: const Color(0xFF6A1B9A),
                      title: 'Qualifications that fit',
                      count: quals.length,
                      expanded: _qualsExpanded,
                      onToggle: () => setState(
                          () => _qualsExpanded = !_qualsExpanded),
                      children:
                          quals.map((q) => _qualTile(q)).toList(),
                      emptyMessage:
                          'No qualifications match these subjects yet.',
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // ---------- SUBJECT CHIP ----------
  Widget _subjectChip(String subject) {
    final selected = _selected.contains(subject);
    return GestureDetector(
      onTap: () => _toggle(subject),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_circle,
                  color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              subject,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- EMPTY HINT ----------
  Widget _emptyHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(Icons.touch_app_outlined,
              size: 40, color: AppColors.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          const Text(
            'Select at least one subject to see your matches.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ---------- EXPANDABLE PANEL ----------
  Widget _expandablePanel({
    required IconData icon,
    required Color color,
    required String title,
    required int count,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
    required String emptyMessage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count',
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: children.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(emptyMessage,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13)),
                    )
                  : Column(children: children),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  // ---------- RESULT TILES ----------
  Widget _careerTile(Map<String, dynamic> c) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CareerDetailScreen(career: c)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00695C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.work_outline,
                  color: Color(0xFF00695C), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c['title'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    (c['description'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _qualTile(Map<String, dynamic> q) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => QualificationDetailScreen(qualification: q)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_outlined,
                  color: Color(0xFF6A1B9A), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q['name'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    (q['description'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}