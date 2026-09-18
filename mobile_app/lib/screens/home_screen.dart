import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../services/language_service.dart';
import '../services/cache_service.dart';
import '../services/auth_service.dart';
import '../main.dart';

import 'quiz_screen.dart';
import 'subject_chooser_screen.dart';
import 'qualifications_screen.dart';
import 'providers_screen.dart';
import 'ai_chat_screen.dart';
import 'advisor_screen.dart';
import 'events_screen.dart';
import 'settings_screen.dart';
import 'reminders_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: languageService,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ---------- OFFLINE BANNER ----------
            SliverToBoxAdapter(
              child: FutureBuilder<bool>(
                future: CacheService.isOffline(),
                builder: (context, snap) {
                  if (snap.data != true) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    color: Colors.orange.shade100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_off,
                            size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Offline mode — showing cached data',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ---------- HERO HEADER ----------
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                      _headerRow(context),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.t(context, 'greeting'),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.t(context, 'tagline'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppStrings.t(context, 'search_hint'),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- EXPLORE ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(AppStrings.t(context, 'explore'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // ---- NEW: QUIZ TILE (replaces Careers) ----
                    Expanded(
                      child: _exploreItem(
                        context,
                        icon: Icons.auto_awesome,
                        label: 'Career Quiz',
                        sub: 'Find your fit',
                        color: const Color(0xFF00695C),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  QuizScreen(type: 'career_choice')),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _exploreItem(
                        context,
                        icon: Icons.school_outlined,
                        label: AppStrings.t(context, 'subjects'),
                        sub: 'What to take',
                        color: const Color(0xFF3949AB),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SubjectChooserScreen()),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _exploreItem(
                        context,
                        icon: Icons.menu_book_outlined,
                        label: AppStrings.t(context, 'what_to_study'),
                        sub: 'Qualifications',
                        color: const Color(0xFF6A1B9A),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const QualificationsScreen()),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _exploreItem(
                        context,
                        icon: Icons.location_on_outlined,
                        label: AppStrings.t(context, 'where_to_study'),
                        sub: 'Institutions',
                        color: const Color(0xFFEF6C00),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProvidersScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- YOUR TOOLS ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                child: Text('Your tools',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                      // ---- Job Fit stays here ----
                      _toolRow(
                        context,
                        icon: Icons.badge_outlined,
                        color: const Color(0xFF00695C),
                        title: AppStrings.t(context, 'quiz_job_fit'),
                        subtitle: 'Which jobs suit you?',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  QuizScreen(type: 'job_fit')),
                        ),
                      ),
                      const Divider(height: 1, indent: 68),
                      _toolRow(
                        context,
                        icon: Icons.support_agent,
                        color: const Color(0xFF00897B),
                        title: AppStrings.t(context, 'advisor'),
                        subtitle: 'Real human help',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdvisorScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 68),
                      _toolRow(
                        context,
                        icon: Icons.event_outlined,
                        color: const Color(0xFFEF6C00),
                        title: AppStrings.t(context, 'events'),
                        subtitle: 'Workshops & open days',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EventsScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 68),
                      _toolRow(
                        context,
                        icon: Icons.notifications_active_outlined,
                        color: const Color(0xFF00897B),
                        title: 'Reminders',
                        subtitle: 'Stay on track',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RemindersScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        _floatingAiButton(context),
      ],
    );
  }

  Widget _headerRow(BuildContext context) {
    final loggedIn = AuthService.isLoggedIn;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              const Icon(Icons.school, color: Colors.white, size: 26),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          icon: const Icon(Icons.notifications_none,
              color: Colors.white),
        ),
        if (!loggedIn) ...[
          const SizedBox(width: 4),
          _pillButton(
            context,
            label: 'Sign in',
            filled: false,
            onTap: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
              );
              if (ok == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 6),
          _pillButton(
            context,
            label: 'Register',
            filled: true,
            onTap: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => const RegisterScreen()),
              );
              if (ok == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (route) => false,
                );
              }
            },
          ),
        ] else ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => selectedTab.value = 3,
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person,
                  color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ],
    );
  }

  Widget _pillButton(BuildContext context,
      {required String label,
      required bool filled,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.7), width: 1.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? AppColors.primary : Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _exploreItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _floatingAiButton(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 90,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatScreen()),
        ),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFFFFB300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00695C).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome,
              color: Colors.white, size: 28),
        ),
      ),
    );
  }
}