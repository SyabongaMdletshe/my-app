import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'theme_screen.dart';
import 'privacy_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';
import 'reminders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _savedCount = 0;
  int _quizCount = 0;
  String? _firstName;
  String? _surname;
  String? _email;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    _email = user.email;

    final profile = await AuthService.getProfile();
    if (profile != null) {
      _firstName = profile['name'];
      _surname = profile['surname'];
    }

    final saved = await SupabaseService.client
        .from('journeys')
        .select()
        .eq('user_id', user.id)
        .eq('data->>type', 'saved_career');

    final quizzes = await SupabaseService.client
        .from('journeys')
        .select()
        .eq('user_id', user.id)
        .inFilter('data->>type', ['career_choice', 'job_fit']);

    if (!mounted) return;
    setState(() {
      _savedCount = (saved as List).length;
      _quizCount = (quizzes as List).length;
    });
  }

  Future<void> _editProfile() async {
    final nameCtrl = TextEditingController(text: _firstName ?? '');
    final surnameCtrl = TextEditingController(text: _surname ?? '');

    final save = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: surnameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Surname',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (save != true) return;

    final user = AuthService.currentUser;
    if (user == null) return;

    try {
      await SupabaseService.client.from('profiles').upsert({
        'id': user.id,
        'name': nameCtrl.text.trim(),
        'surname': surnameCtrl.text.trim(),
        'email': user.email,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated ✅')),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final ctrl = TextEditingController();
    final newPass = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'At least 6 characters',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newPass == null || newPass.length < 6) return;

    try {
      await SupabaseService.client.auth
          .updateUser(UserAttributes(password: newPass));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
            'This will permanently remove your account and all saved data. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
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
      final user = AuthService.currentUser;
      if (user == null) return;

      await SupabaseService.client
          .from('journeys')
          .delete()
          .eq('user_id', user.id);

      await SupabaseService.client
          .from('profiles')
          .delete()
          .eq('id', user.id);

      await AuthService.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.isLoggedIn;

    final displayName = (_firstName != null && _firstName!.isNotEmpty)
        ? '$_firstName ${_surname ?? ''}'.trim()
        : (isLoggedIn ? (_email ?? 'Signed in') : 'Guest user');

    final initial = (_firstName != null && _firstName!.isNotEmpty)
        ? _firstName![0].toUpperCase()
        : (isLoggedIn && _email != null && _email!.isNotEmpty
            ? _email![0].toUpperCase()
            : 'G');

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---------- HEADER CARD ----------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00695C).withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        child: Text(
                          initial,
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (_email != null && isLoggedIn) ...[
                              const SizedBox(height: 4),
                              Text(_email!,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isLoggedIn ? _editProfile : null,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.7)),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------- STATS ----------
            Row(
              children: [
                Expanded(
                  child: _statCard(Icons.bookmark, '$_savedCount',
                      'Saved', const Color(0xFF00695C)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(Icons.quiz, '$_quizCount', 'Quizzes',
                      const Color(0xFF3949AB)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ---------- ACCOUNT ----------
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Text('Account',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Container(
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
                  _settingsRow(
                    icon: Icons.lock_outline,
                    title: 'Change password',
                    onTap: isLoggedIn ? _changePassword : null,
                  ),
                  const Divider(height: 1, indent: 56),
                  _settingsRow(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications & language',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _settingsRow(
                    icon: Icons.alarm_outlined,
                    title: 'Reminders',
                    subtitle: 'Daily nudges & deadlines',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RemindersScreen()),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _settingsRow(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    subtitle: 'Light / Dark / System',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ThemeScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- ABOUT ----------
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Text('About',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Container(
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
                  _settingsRow(
                    icon: Icons.info_outline,
                    title: 'Khetha NCAP Mobile',
                    subtitle: 'Version 1.0.0',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AboutScreen()),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _settingsRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    subtitle: 'How we protect your data',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyScreen()),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _settingsRow(
                    icon: Icons.help_outline,
                    title: 'Help & Feedback',
                    subtitle: 'Contact us & FAQs',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HelpScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- SIGN OUT ----------
            if (isLoggedIn)
              OutlinedButton.icon(
                onPressed: () async {
                  await AuthService.logout();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out')),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

            const SizedBox(height: 10),

            // ---------- DELETE ACCOUNT ----------
            if (isLoggedIn)
              TextButton.icon(
                onPressed: _deleteAccount,
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('Delete my account'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(44),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------- helpers ----------
  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}