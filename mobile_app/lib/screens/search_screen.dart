import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/cache_service.dart';
import '../theme/app_theme.dart';
import 'career_detail_screen.dart';
import 'qualifications_screen.dart';
import 'providers_screen.dart';
import 'advisor_screen.dart';
import 'events_screen.dart';
import 'qualification_detail_screen.dart';
import 'provider_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  bool _loading = true;

  List<Map<String, dynamic>> _careers = [];
  List<Map<String, dynamic>> _qualifications = [];
  List<Map<String, dynamic>> _providers = [];
  List<Map<String, dynamic>> _advisors = [];
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      CacheService.fetchList('careers', orderBy: 'title'),
      CacheService.fetchList('qualifications', orderBy: 'name'),
      CacheService.fetchList('providers', orderBy: 'name'),
      CacheService.fetchList('advisors', orderBy: 'name'),
      CacheService.fetchList('events', orderBy: 'event_date'),
    ]);

    if (!mounted) return;
    setState(() {
      _careers = results[0];
      _qualifications = results[1];
      _providers = results[2];
      _advisors = results[3];
      _events = results[4];
      _loading = false;
    });
  }

  bool _match(String? value, String q) {
    if (q.isEmpty) return false;
    return (value ?? '').toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();

    final careerHits = q.isEmpty
        ? <Map<String, dynamic>>[]
        : _careers
            .where((c) =>
                _match(c['title'], q) || _match(c['description'], q))
            .toList();

    final qualHits = q.isEmpty
        ? <Map<String, dynamic>>[]
        : _qualifications
            .where((c) =>
                _match(c['name'], q) ||
                _match(c['description'], q) ||
                _match(c['requirements'], q))
            .toList();

    final providerHits = q.isEmpty
        ? <Map<String, dynamic>>[]
        : _providers
            .where((p) =>
                _match(p['name'], q) ||
                _match(p['city'], q) ||
                _match(p['province'], q) ||
                _match(p['type'], q))
            .toList();

    final advisorHits = q.isEmpty
        ? <Map<String, dynamic>>[]
        : _advisors
            .where((a) =>
                _match(a['name'], q) ||
                _match(a['role'], q) ||
                _match(a['province'], q))
            .toList();

    final eventHits = q.isEmpty
        ? <Map<String, dynamic>>[]
        : _events
            .where((e) =>
                _match(e['title'], q) ||
                _match(e['description'], q) ||
                _match(e['location'], q) ||
                _match(e['province'], q))
            .toList();

    final totalHits = careerHits.length +
        qualHits.length +
        providerHits.length +
        advisorHits.length +
        eventHits.length;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search everything…',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : q.isEmpty
              ? _emptyState(
                  icon: Icons.search,
                  title: 'Search everything',
                  subtitle:
                      'Find careers, qualifications, institutions, advisors and events.',
                )
              : totalHits == 0
                  ? _emptyState(
                      icon: Icons.search_off,
                      title: 'No results for "$_query"',
                      subtitle: 'Try a different word or spelling.',
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _sectionHeader(
                            'Careers', careerHits.length, Icons.work_outline),
                        ...careerHits.map(_careerTile),
                        _sectionHeader('Qualifications',
                            qualHits.length, Icons.menu_book_outlined),
                        ...qualHits.map(_qualTile),
                        _sectionHeader('Where to Study',
                            providerHits.length, Icons.location_on_outlined),
                        ...providerHits.map(_providerTile),
                        _sectionHeader('Career Advisors',
                            advisorHits.length, Icons.support_agent),
                        ...advisorHits.map(_advisorTile),
                        _sectionHeader('Career Events',
                            eventHits.length, Icons.event_outlined),
                        ...eventHits.map(_eventTile),
                        const SizedBox(height: 40),
                      ],
                    ),
    );
  }

  Widget _emptyState(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: AppColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, int count, IconData icon) {
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ---------------- tiles ----------------
  Widget _careerTile(Map<String, dynamic> c) {
    return _tile(
      leading: Icons.work_outline,
      color: const Color(0xFF00695C),
      title: c['title'] ?? '',
      subtitle: c['description'] ?? '',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CareerDetailScreen(career: c),
        ),
      ),
    );
  }

   Widget _qualTile(Map<String, dynamic> q) {
    return _tile(
      leading: Icons.menu_book_outlined,
      color: const Color(0xFF6A1B9A),
      title: q['name'] ?? '',
      subtitle: q['description'] ?? '',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QualificationDetailScreen(qualification: q),
        ),
      ),
    );
  }

  Widget _providerTile(Map<String, dynamic> p) {
    return _tile(
      leading: Icons.location_on_outlined,
      color: const Color(0xFFEF6C00),
      title: p['name'] ?? '',
      subtitle:
          '${p['type'] ?? ''} • ${p['city'] ?? ''}, ${p['province'] ?? ''}',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProviderDetailScreen(provider: p)),
      ),
    );
  }

  Widget _advisorTile(Map<String, dynamic> a) {
    return _tile(
      leading: Icons.support_agent,
      color: const Color(0xFF00897B),
      title: a['name'] ?? '',
      subtitle: '${a['role'] ?? ''} • ${a['province'] ?? ''}',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdvisorScreen()),
      ),
    );
  }

  Widget _eventTile(Map<String, dynamic> e) {
    return _tile(
      leading: Icons.event_outlined,
      color: const Color(0xFFEF6C00),
      title: e['title'] ?? '',
      subtitle: '${e['event_date'] ?? ''} • ${e['location'] ?? ''}',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EventsScreen()),
      ),
    );
  }

  Widget _tile({
    required IconData leading,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(leading, color: color, size: 20),
        ),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 12)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}