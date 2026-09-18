import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../services/language_service.dart';
import 'career_detail_screen.dart';
import 'quiz_screen.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  void _reload() {
    _future = SupabaseService.client
        .from('journeys')
        .select()
        .order('saved_at', ascending: false);
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: languageService,
      builder: (context, _) => _buildBody(context),
    );
  }

  Future<void> _delete(Map<String, dynamic> j) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('Remove this from your journey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await SupabaseService.client
          .from('journeys')
          .delete()
          .eq('id', j['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted ✅')),
        );
        setState(_reload);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF00897B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.t(context, 'journey_title'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(AppStrings.t(context, 'journey_tagline'),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppStrings.t(context, 'journey_empty'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textMuted, height: 1.5),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final j = items[i];
                  final data = j['data'] as Map<String, dynamic>? ?? {};
                  final type = data['type'] ?? 'saved';
                  final tags = data['tags'] as Map<String, dynamic>? ?? {};

                  String title;
                  IconData icon;
                  Color color;

                  if (type == 'career_choice') {
                    title = AppStrings.t(context, 'quiz_career_choice');
                    icon = Icons.psychology_outlined;
                    color = const Color(0xFF3949AB);
                  } else if (type == 'job_fit') {
                    title = AppStrings.t(context, 'quiz_job_fit');
                    icon = Icons.badge_outlined;
                    color = const Color(0xFF00695C);
                  } else if (type == 'saved_career') {
                    title = data['title'] ?? 'Saved Career';
                    icon = Icons.bookmark;
                    color = AppColors.primary;
                  } else {
                    title = 'Journey Entry';
                    icon = Icons.star_outline;
                    color = AppColors.accent;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (type == 'saved_career') {
                        final career = <String, dynamic>{
                          'id': j['career_id'],
                          'title': data['title'],
                          'description': data['description'],
                          'subjects': data['subjects'],
                          'tasks': data['tasks'],
                        };
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CareerDetailScreen(career: career),
                          ),
                        );
                      } else if (type == 'career_choice') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                QuizScreen(type: 'career_choice'),
                          ),
                        );
                      } else if (type == 'job_fit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                QuizScreen(type: 'job_fit'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                                const SizedBox(height: 4),
                                if (tags.isNotEmpty)
                                  Text(
                                    tags.keys
                                        .take(3)
                                        .map((t) => t.toUpperCase())
                                        .join(' · '),
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            (j['saved_at'] as String? ?? '')
                                .substring(0, 10),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.error),
                            tooltip: 'Delete',
                            onPressed: () => _delete(j),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}