import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/create_group_screen.dart';
import 'screens/create_village_screen.dart';
import 'screens/sofa_loan_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/edit_entry_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/login_screen.dart';
import 'screens/new_entry_screen.dart';
import 'screens/reports/audit_log_screen.dart';
import 'screens/reports/interest_report_screen.dart';
import 'screens/reports/bank_flow_screen.dart';
import 'screens/reports/group_health_screen.dart';
import 'screens/reports/overdue_alerts_screen.dart';
import 'screens/reports/recovery_rate_screen.dart';
import 'screens/reports/savings_overview_screen.dart';
import 'screens/reports/sofa_loans_screen.dart';
import 'screens/reports/trends_screen.dart';
import 'screens/reports/village_compare_screen.dart';
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
          GoRoute(
            path: '/reports/savings',
            builder: (_, __) => const SavingsOverviewScreen(),
          ),
          GoRoute(
            path: '/reports/savings/village/:name',
            builder: (context, state) {
              final name =
                  Uri.decodeComponent(state.pathParameters['name']!);
              return VillageSavingsScreen(villageName: name);
            },
          ),
          GoRoute(
            path: '/reports/savings/group/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return GroupSavingsScreen(groupId: id);
            },
          ),
          // Interest Earned detail
          GoRoute(
            path: '/reports/interest',
            builder: (_, __) => const InterestReportScreen(),
          ),

          // SOFA Loans (3-level)
          GoRoute(
            path: '/reports/sofa',
            builder: (_, __) => const SofaLoansScreen(),
          ),
          GoRoute(
            path: '/reports/sofa/village/:name',
            builder: (context, state) {
              final name = Uri.decodeComponent(state.pathParameters['name']!);
              return VillageSofaScreen(villageName: name);
            },
          ),
          GoRoute(
            path: '/reports/sofa/group/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return GroupSofaScreen(groupId: id);
            },
          ),
          // Bank Flow (3-level)
          GoRoute(
            path: '/reports/bank',
            builder: (_, __) => const BankFlowScreen(),
          ),
          GoRoute(
            path: '/reports/bank/village/:name',
            builder: (context, state) {
              final name = Uri.decodeComponent(state.pathParameters['name']!);
              return VillageBankScreen(villageName: name);
            },
          ),
          GoRoute(
            path: '/reports/bank/group/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return GroupBankScreen(groupId: id);
            },
          ),
          // Village Compare (1-level)
          GoRoute(
            path: '/reports/compare',
            builder: (_, __) => const VillageCompareScreen(),
          ),
          // Overdue Alerts (1-level)
          GoRoute(
            path: '/reports/overdue',
            builder: (_, __) => const OverdueAlertsScreen(),
          ),
          // Trends (1-level)
          GoRoute(
            path: '/reports/trends',
            builder: (_, __) => const TrendsScreen(),
          ),
          // Group Health (2-level)
          GoRoute(
            path: '/reports/health',
            builder: (_, __) => const GroupHealthScreen(),
          ),
          GoRoute(
            path: '/reports/health/village/:name',
            builder: (context, state) {
              final name = Uri.decodeComponent(state.pathParameters['name']!);
              return VillageHealthScreen(villageName: name);
            },
          ),
          // Recovery Rate (2-level)
          GoRoute(
            path: '/reports/recovery',
            builder: (_, __) => const RecoveryRateScreen(),
          ),
          GoRoute(
            path: '/reports/recovery/village/:name',
            builder: (context, state) {
              final name = Uri.decodeComponent(state.pathParameters['name']!);
              return VillageRecoveryScreen(villageName: name);
            },
          ),
          // Audit Log (2-level, admin only)
          GoRoute(
            path: '/reports/audit',
            builder: (_, __) => const AuditLogScreen(),
          ),
          GoRoute(
            path: '/reports/audit/village/:name',
            builder: (context, state) {
              final name = Uri.decodeComponent(state.pathParameters['name']!);
              return VillageAuditScreen(villageName: name);
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
        path: '/groups/:groupId/sofa',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['groupId']!);
          return GroupSofaLoanScreen(groupId: id);
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
