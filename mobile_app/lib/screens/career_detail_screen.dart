import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'qualifications_screen.dart';

class CareerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> career;
  const CareerDetailScreen({super.key, required this.career});

  String _fmt(int? v) {
    if (v == null || v <= 0) return '';
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return 'R ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final subjects = (career['subjects'] as List?)?.cast<String>() ?? [];
    final tasks = (career['tasks'] as List?)?.cast<String>() ?? [];
    final salMin = career['salary_min'] as int?;
    final salMax = career['salary_max'] as int?;
    final hasSalary = salMin != null && salMin > 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(career['title'] ?? '',
                  style: const TextStyle(fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.work_outline,
                      color: Colors.white, size: 80),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- ABOUT ----------
                  const Text('About this career',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    career['description'] ?? '',
                    style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),

                  // ---------- SALARY ----------
                  if (hasSalary)
                    _salaryCard(salMin!, salMax ?? salMin)
                  else
                    _salaryComingSoon(context),

                  const SizedBox(height: 24),

                  // ---------- TASKS ----------
                  if (tasks.isNotEmpty) ...[
                    const Text('What the job involves',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...tasks.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(t,
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 14,
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // ---------- SUBJECTS ----------
                  const Text('Recommended school subjects',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subjects
                        .map((s) => Chip(
                              label: Text(s),
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              side: BorderSide.none,
                              labelStyle: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // ---------- ACTIONS ----------
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QualificationsScreen(
                          careerFilter: career['title'] as String?,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('See qualifications to study this'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await SupabaseService.client
                            .from('journeys')
                            .insert({
                          'user_id': AuthService.currentUser?.id,
                          'career_id': career['id'],
                          'data': {
                            'type': 'saved_career',
                            'title': career['title'],
                            'description': career['description'],
                            'subjects': career['subjects'],
                            'tasks': career['tasks'],
                            'salary_min': career['salary_min'],
                            'salary_max': career['salary_max'],
                          },
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Saved to your journey ✅')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Save to my journey'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- SALARY CARD ----------
  Widget _salaryCard(int min, int max) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE0F2F1),
            const Color(0xFFE0F2F1).withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Expected salary in SA',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${_fmt(min)} – ${_fmt(max)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          const Text('per month',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 12.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              _pill('Entry', _fmt(min)),
              const SizedBox(width: 10),
              _pill('Senior', '${_fmt(max)}+'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 14,
                  color: AppColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Estimates from the SA job market. Actual pay varies by employer, experience and province.',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _salaryComingSoon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.payments_outlined,
              color: AppColors.textMuted, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text('Salary information coming soon',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}