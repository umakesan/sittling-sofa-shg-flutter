import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/edit_entry_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/login_screen.dart';
import 'screens/new_entry_screen.dart';
import 'models/month_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore session from secure storage before the first frame renders,
  // so the router redirect starts with the correct auth state.
  final container = ProviderContainer();
  await container.read(authProvider.notifier).tryRestoreSession();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ShgApp(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Router — declared as a Provider so it is created once and can read Riverpod.
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
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
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
        path: '/ledger/:groupId',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['groupId']!);
          return LedgerScreen(groupId: id);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
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
    return MaterialApp.router(
      title: 'SHG Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      routerConfig: router,
    );
  }
}
