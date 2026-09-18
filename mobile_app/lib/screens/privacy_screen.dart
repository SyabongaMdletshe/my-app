import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Section(
            icon: Icons.shield_outlined,
            title: 'Your data is safe',
            body:
                'Khetha stores your personal information securely using Supabase — a trusted cloud platform with encryption at rest and in transit.',
          ),
          _Section(
            icon: Icons.person_outline,
            title: 'What we collect',
            body:
                '• Name and surname (to personalise your experience)\n• Email (for your account)\n• Career choices and quiz results (to remember your journey)\n\nWe do NOT collect your location, contacts, or photos.',
          ),
          _Section(
            icon: Icons.lock_outline,
            title: 'How we protect it',
            body:
                'Your data is stored in a secure Supabase database. Row-level security ensures you can only see your own information.',
          ),
          _Section(
            icon: Icons.share_outlined,
            title: 'We never sell your data',
            body:
                'Khetha never shares your personal information with advertisers or third parties. Your career journey stays yours.',
          ),
          _Section(
            icon: Icons.delete_outline,
            title: 'Delete your account',
            body:
                'You can request deletion of your account and all associated data at any time by emailing info@careerhelp.org.za.',
          ),
          _Section(
            icon: Icons.verified_outlined,
            title: 'POPIA compliant',
            body:
                'We follow South Africa\'s Protection of Personal Information Act (POPIA). You have the right to access, correct, or delete your data.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(body,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13.5, height: 1.5)),
        ],
      ),
    );
  }
}