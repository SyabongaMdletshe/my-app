import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../services/cache_service.dart';
import '../theme/app_theme.dart';

class QualificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> qualification;
  const QualificationDetailScreen({super.key, required this.qualification});

  @override
  State<QualificationDetailScreen> createState() =>
      _QualificationDetailScreenState();
}

class _QualificationDetailScreenState
    extends State<QualificationDetailScreen> {
  List<Map<String, dynamic>> _matchingProviders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      final all = await CacheService.fetchList('providers', orderBy: 'name');
      // Basic heuristic: show all universities for degrees, TVETs for diplomas
      final name = (widget.qualification['name'] ?? '').toString().toLowerCase();
      final isDegree = name.contains('bsc') ||
          name.contains('beng') ||
          name.contains('ba ') ||
          name.contains('bcom') ||
          name.contains('barch') ||
          name.contains('llb') ||
          name.contains('mbchb') ||
          name.contains('bchd') ||
          name.contains('boptom') ||
          name.contains('bpharm') ||
          name.contains('b.ed') ||
          name.contains('bed');

      final filtered = all.where((p) {
        if (isDegree) return p['type'] == 'University';
        return p['type'] == 'TVET College' || p['type'] == 'Private';
      }).toList();

      if (!mounted) return;
      setState(() {
        _matchingProviders = filtered.take(6).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.qualification;
    final careers = (q['careers'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(q['name'] ?? '',
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.menu_book_outlined,
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
                  // Description
                  _section(
                    icon: Icons.info_outline,
                    title: 'About this qualification',
                    body: q['description'] ?? '',
                  ),

                  // Duration
                  _section(
                    icon: Icons.schedule,
                    title: 'Duration',
                    body: q['duration'] ?? 'Not specified',
                  ),

                  // Requirements
                  _section(
                    icon: Icons.checklist,
                    title: 'Entry requirements',
                    body: q['requirements'] ?? 'See institution for details',
                  ),

                  // Careers
                  if (careers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.work_outline,
                            size: 20, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Careers this leads to',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: careers
                          .map((c) => Chip(
                                label: Text(c),
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Providers
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_matchingProviders.isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined,
                            size: 20, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Where you can study this',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._matchingProviders.map(_providerCard),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(body,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.55)),
        ],
      ),
    );
  }

  Widget _providerCard(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.account_balance,
              color: AppColors.primary, size: 20),
        ),
        title: Text(p['name'] ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('${p['city'] ?? ''}, ${p['province'] ?? ''}',
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 12)),
        trailing: (p['website'] ?? '').toString().isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.open_in_new,
                    color: AppColors.primary, size: 18),
                onPressed: () async {
                  final uri = Uri.parse(p['website']);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
              )
            : null,
      ),
    );
  }
}