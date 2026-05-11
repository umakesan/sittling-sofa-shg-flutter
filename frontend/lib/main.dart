import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/create_group_screen.dart';
import 'screens/create_village_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/edit_entry_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/login_screen.dart';
import 'screens/new_entry_screen.dart';
import 'models/month_entry.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(authProvider.notifier).tryRestoreSession();
  await container.read(localeProvider.notifier).loadSaved();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ShgApp(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

final _routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(routerAuthNotifierProvider);
  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final user = ref.read(authProvider);
      final onLogin = state.matchedLocation == '/login';
      if (user == null && !onLogin) return '/login';
      if (user != null && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/ledger/:groupId',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['groupId']!);
              return LedgerScreen(groupId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/entries/new',
        builder: (context, state) => const NewEntryScreen(),
      ),
      GoRoute(
        path: '/entries/edit',
        builder: (context, state) {
          final entry = state.extra as MonthEntry;
          return EditEntryScreen(entry: entry);
        },
      ),
      GoRoute(
        path: '/admin/create-village',
        builder: (context, state) => const CreateVillageScreen(),
      ),
      GoRoute(
        path: '/admin/create-group',
        builder: (context, state) => const CreateGroupScreen(),
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

class ShgApp extends ConsumerWidget {
  const ShgApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'SHG Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: appSupportedLocales,
      routerConfig: router,
    );
  }
}
