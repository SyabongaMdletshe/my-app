import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/language_service.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    languageService.addListener(_onLang);
  }

  @override
  void dispose() {
    languageService.removeListener(_onLang);
    super.dispose();
  }

  void _onLang() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- LANGUAGE ----------
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text('Language / Ulimi / Puo / Taal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: AppStrings.languageNames.entries.map((entry) {
                final selected =
                    languageService.locale.languageCode == entry.key;
                return RadioListTile<String>(
                  value: entry.key,
                  groupValue: languageService.locale.languageCode,
                  activeColor: AppColors.primary,
                  title: Text(entry.value),
                  onChanged: (v) {
                    if (v != null) languageService.setLanguage(v);
                  },
                  selected: selected,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // ---------- TEST NOTIFICATION ----------
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text('Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await NotificationService.showNow(
                title: 'Khetha',
                body: 'New career opportunities have been added 🎓',
              );
            },
            icon: const Icon(Icons.notifications),
            label: const Text('Send test notification'),
          ),

          const SizedBox(height: 24),

          // ---------- ACCESSIBILITY ----------
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text('Accessibility',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            leading: Icon(Icons.text_fields, color: AppColors.primary),
            title: Text('Large text'),
            subtitle: Text('Follows your system font size setting'),
          ),
        ],
      ),
    );
  }
}