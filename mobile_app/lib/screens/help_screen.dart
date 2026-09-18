import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _email(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF00897B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent,
                    color: Colors.white, size: 40),
                SizedBox(height: 12),
                Text('We are here to help',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                    'Contact the Khetha team for any questions, feedback or assistance.',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text('Contact us',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          _contactTile(
            icon: Icons.phone,
            title: '0800 20 22 22',
            subtitle: 'Toll-free helpline',
            onTap: () => _call('0800202222'),
          ),
          _contactTile(
            icon: Icons.email_outlined,
            title: 'info@careerhelp.org.za',
            subtitle: 'Email our team',
            onTap: () => _email('info@careerhelp.org.za'),
          ),
          _contactTile(
            icon: Icons.language,
            title: 'www.careerhelp.org.za',
            subtitle: 'Visit our website',
            onTap: () async {
              final uri = Uri.parse('https://www.careerhelp.org.za');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              }
            },
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text('Frequently asked questions',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          const _Faq(
            q: 'How do I save my career journey?',
            a:
                'Tap "Save to my journey" on any career detail screen. Log in with an email to sync across devices.',
          ),
          const _Faq(
            q: 'Is my data private?',
            a:
                'Yes — see the Privacy section. We never sell your data and you can delete it anytime.',
          ),
          const _Faq(
            q: 'Can I use Khetha offline?',
            a:
                'Once you open a section online, it stays available for offline use. A banner shows when you are offline.',
          ),
          const _Faq(
            q: 'Who can I talk to for career advice?',
            a:
                'Use "Talk to a Career Advisor" from the Home screen to reach a human career practitioner.',
          ),
        ],
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14.5)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 12)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  final String q;
  final String a;
  const _Faq({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(q,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(a,
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}