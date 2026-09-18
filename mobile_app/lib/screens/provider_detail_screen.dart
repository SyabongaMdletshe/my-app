import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/cache_service.dart';

class ProviderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  List<Map<String, dynamic>> _relatedQuals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRelated();
  }

  Future<void> _loadRelated() async {
    try {
      final type = widget.provider['type'] ?? '';
      final all = await CacheService.fetchList('qualifications', orderBy: 'name');

      // Filter qualifications based on provider type
      final list = all.where((q) {
        final n = (q['name'] ?? '').toString().toLowerCase();
        final isDegree = n.contains('bsc') ||
            n.contains('beng') ||
            n.contains('ba ') ||
            n.contains('bcom') ||
            n.contains('barch') ||
            n.contains('llb') ||
            n.contains('mbchb') ||
            n.contains('bchd') ||
            n.contains('boptom') ||
            n.contains('bpharm') ||
            n.contains('bed');
        if (type == 'University') return isDegree;
        if (type == 'TVET College') return !isDegree;
        return !isDegree; // Private
      }).take(6).toList();

      if (!mounted) return;
      setState(() {
        _relatedQuals = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openWebsite(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'University':
        return const Color(0xFF00695C);
      case 'TVET College':
        return const Color(0xFF3949AB);
      case 'Private':
        return const Color(0xFF6A1B9A);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final type = (p['type'] ?? '').toString();
    final color = _typeColor(type);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(p['name'] ?? '',
                  maxLines: 2, style: const TextStyle(fontSize: 14)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.account_balance,
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
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(type,
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info card
                  _infoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    body: '${p['city'] ?? ''}, ${p['province'] ?? ''}',
                  ),
                  _infoCard(
                    icon: Icons.public,
                    title: 'Province',
                    body: p['province'] ?? '—',
                  ),

                  if ((p['website'] ?? '').toString().isNotEmpty)
                    _infoCard(
                      icon: Icons.language,
                      title: 'Website',
                      body: p['website'],
                      actionLabel: 'Visit website',
                      onAction: () => _openWebsite(p['website']),
                    ),

                  const SizedBox(height: 12),

                  // Related qualifications
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_relatedQuals.isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.menu_book_outlined,
                            size: 20, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Qualifications offered',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._relatedQuals.map(_qualTile),
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

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String body,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                  height: 1.5)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(actionLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _qualTile(Map<String, dynamic> q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book_outlined,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(q['name'] ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}