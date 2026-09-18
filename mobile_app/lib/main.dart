import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';
import 'screens/careers_screen.dart';
import 'screens/journey_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_strings.dart';
import 'services/language_service.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
    await NotificationService.init();
  runApp(const KhethaApp());
}

final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

class KhethaApp extends StatelessWidget {
  const KhethaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([languageService, themeService]),
      builder: (context, _) {
        return MaterialApp(
          key: ValueKey(
              '${languageService.locale.languageCode}_${themeService.mode}'),
          title: 'Khetha',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeService.mode,
          home: AuthService.isLoggedIn
              ? const MainShell()
              : const LoginScreen(),
        );
      },
    );
  }
}
class MainShellRoute extends StatelessWidget {
  const MainShellRoute({super.key});

  @override
  Widget build(BuildContext context) => const MainShell();
}
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _screens = [
    HomeScreen(),
    CareersScreen(),
    JourneyScreen(),
    ProfileScreen(),
  ];


  @override
  void initState() {
    super.initState();
    selectedTab.addListener(_onTab);
  }

  @override
  void dispose() {
    selectedTab.removeListener(_onTab);
    super.dispose();
  }

  void _onTab() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final index = selectedTab.value;
    return Scaffold(
      body: SafeArea(child: _screens[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => selectedTab.value = i,
               destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home),
              label: AppStrings.t(context, 'nav_home')),
          NavigationDestination(
              icon: const Icon(Icons.work),
              label: AppStrings.t(context, 'nav_careers')),
          NavigationDestination(
              icon: const Icon(Icons.timeline),
              label: AppStrings.t(context, 'nav_journey')),
          NavigationDestination(
              icon: const Icon(Icons.person),
              label: AppStrings.t(context, 'nav_profile')),
        ],
      ),
    );
  }
}