import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Khetha')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF00897B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(Icons.school, color: Colors.white, size: 72),
                SizedBox(height: 12),
                Text('Khetha',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('NCAP Mobile',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('Version 1.0.0',
                    style:
                        TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _section(
            title: 'What is Khetha?',
            body:
                'Khetha is the National Career Advice Portal (NCAP) mobile app, brought to you by the Department of Higher Education and Training (DHET). It helps South Africans make informed decisions about careers, subjects, qualifications and study options.',
          ),

          _section(
            title: 'What you can do',
            body:
                '• Explore over 100 careers\n'
                '• Use the Subject Chooser\n'
                '• Take the Career Choice & Job Fit quizzes\n'
                '• Find qualifications (What to Study)\n'
                '• Locate institutions (Where to Study)\n'
                '• Chat with the AI Career Assistant\n'
                '• Reach real career advisors\n'
                '• Save your personalised career journey',
          ),

          _section(
            title: 'Built for every South African',
            body:
                'Khetha works on basic smartphones, supports multiple languages, and keeps working even when you are offline. It follows POPIA privacy standards and is designed for inclusivity.',
          ),

          _section(
            title: 'Acknowledgements',
            body:
                'Developed for the DHET Khetha NCAP Mobile App Challenge 2026. Content based on the NCAP website (ncap.careerhelp.org.za).',
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              '© 2026 Department of Higher Education and Training',
              style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 11),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section({required String title, required String body}) {
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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13.5, height: 1.55)),
        ],
      ),
    );
  }
}