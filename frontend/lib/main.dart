import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_entry_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    // ProviderScope is Riverpod's equivalent of React Context.Provider —
    // it must wrap the entire app so all providers are reachable.
    const ProviderScope(child: ShgApp()),
  );
}

final _router = GoRouter(
  initialLocation: '/login',
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

class ShgApp extends StatelessWidget {
  const ShgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SHG Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F), // SOFA green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      routerConfig: _router,
    );
  }
}
