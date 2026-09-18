import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  String _theme = 'light';

  @override
  void initState() {
    super.initState();
    _sync();
    themeService.addListener(_sync);
  }

  @override
  void dispose() {
    themeService.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    final m = themeService.mode;
    if (!mounted) return;
    setState(() {
      _theme = m == ThemeMode.dark
          ? 'dark'
          : m == ThemeMode.system
              ? 'system'
              : 'light';
    });
  }

  Future<void> _setTheme(String value) async {
    await themeService.setTheme(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme set to $value')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text('Choose your preferred theme',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'light',
                  groupValue: _theme,
                  activeColor: AppColors.primary,
                  title: const Text('Light'),
                  subtitle: const Text('Default bright theme'),
                  secondary: const Icon(Icons.light_mode_outlined,
                      color: AppColors.primary),
                  onChanged: (v) => _setTheme(v!),
                ),
                const Divider(height: 1, indent: 56),
                RadioListTile<String>(
                  value: 'dark',
                  groupValue: _theme,
                  activeColor: AppColors.primary,
                  title: const Text('Dark'),
                  subtitle: const Text('Easier on the eyes at night'),
                  secondary: const Icon(Icons.dark_mode_outlined,
                      color: AppColors.primary),
                  onChanged: (v) => _setTheme(v!),
                ),
                const Divider(height: 1, indent: 56),
                RadioListTile<String>(
                  value: 'system',
                  groupValue: _theme,
                  activeColor: AppColors.primary,
                  title: const Text('System default'),
                  subtitle: const Text('Follow your phone setting'),
                  secondary: const Icon(Icons.settings_suggest_outlined,
                      color: AppColors.primary),
                  onChanged: (v) => _setTheme(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'The theme changes immediately across the app.',
              style:
                  TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}