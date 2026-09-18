import 'package:flutter/material.dart';
import 'career_detail_screen.dart';
import '../main.dart';

class QuizResultScreen extends StatelessWidget {
  final String quizType;
  final List<MapEntry<Map<String, dynamic>, int>> ranked;

  const QuizResultScreen({
    super.key,
    required this.quizType,
    required this.ranked,
  });

  bool get _isJobFit => quizType == 'job_fit';

  Color _rankColor(int i) {
    switch (i) {
      case 0:
        return const Color(0xFFFFD54F);
      case 1:
        return const Color(0xFFB0BEC5);
      case 2:
        return const Color(0xFFBCAAA4);
      default:
        return const Color(0xFF90A4AE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top3 = ranked.take(3).toList();
    final hasMore = ranked.length > 3;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to home',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            selectedTab.value = 0;
          },
        ),
        title: Text(_isJobFit ? 'Job Fit Results' : 'Career Results'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- HERO ----------
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFFFFB300)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00695C).withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isJobFit
                            ? Icons.badge_outlined
                            : Icons.psychology_outlined,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isJobFit ? 'Great match!' : 'Nice work!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isJobFit
                          ? 'Based on your answers, here are the jobs that fit you best.'
                          : 'Based on your answers, here are careers that suit you.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _isJobFit ? 'TOP JOB MATCHES' : 'TOP CAREER MATCHES',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5F6368),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              // ---------- TOP 3 ----------
              ...List.generate(top3.length, (i) {
                final career = top3[i].key;
                final pct = top3[i].value;
                return _careerCard(context, career, pct, i + 1);
              }),

              if (hasMore) ...[
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => _showAll(context),
                  icon: const Icon(Icons.expand_more, size: 18),
                  label: Text(
                    'See more matches (${ranked.length - 3})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00695C),
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Color(0xFF00695C)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ---------- ACTIONS ----------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // pop result → back to quiz → user can redo
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5F6368),
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        selectedTab.value = 0;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Done',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- CAREER CARD ----------
  Widget _careerCard(
      BuildContext context, Map<String, dynamic> career, int pct, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _rankColor(rank - 1),
                  shape: BoxShape.circle,
                ),
                child: Text('$rank',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  career['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text('$pct%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00695C),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor:
                      const Color(0xFF00695C).withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation(
                      Color(0xFF00695C)),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // ---------- smaller "View career" button ----------
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CareerDetailScreen(career: career)),
              ),
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: const Text('View career',
                  style: TextStyle(fontSize: 12.5)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00695C),
                side: const BorderSide(color: Color(0xFF00695C)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- SEE ALL (bottom sheet with tappable rows) ----------
  void _showAll(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _isJobFit
                    ? 'All job matches (${ranked.length})'
                    : 'All career matches (${ranked.length})',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: ranked.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final career = ranked[i].key;
                    final pct = ranked[i].value;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(context); // close sheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CareerDetailScreen(career: career),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: i < 3
                                      ? _rankColor(i)
                                      : const Color(0xFF90A4AE),
                                  shape: BoxShape.circle,
                                ),
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(career['title'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ),
                              Text('$pct%',
                                  style: const TextStyle(
                                      color: Color(0xFF00695C),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right,
                                  size: 18, color: Color(0xFF5F6368)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}