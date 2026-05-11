import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shg_portal/l10n/app_localizations.dart';

import '../database/sync_service.dart';
import '../providers/auth_provider.dart';
import '../providers/entries_provider.dart';
import '../providers/locale_provider.dart';
import 'sofa_logo.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return child;

    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(authProvider);
    final isAdmin = user?.isAdmin == true;
    final currentLocale = ref.watch(localeProvider);

    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => _onNav(context, i, isAdmin),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SofaLogo(size: 36),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: Text(l10n.home),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart_rounded),
                label: Text(l10n.dashboard),
              ),
              if (isAdmin) ...[
                NavigationRailDestination(
                  icon: const Icon(Icons.location_city_outlined),
                  selectedIcon: const Icon(Icons.location_city_rounded),
                  label: Text(l10n.newVillage),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.group_add_outlined),
                  selectedIcon: const Icon(Icons.group_add_rounded),
                  label: Text(l10n.newGroup),
                ),
              ],
            ],
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sync button — native only (web is always online)
                  if (!kIsWeb) _NavSyncButton(l10n: l10n),
                  const SizedBox(height: 4),

                  // Language switcher
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.translate_rounded),
                    tooltip: l10n.language,
                    initialValue: _localeKey(currentLocale),
                    onSelected: (val) {
                      final locale = switch (val) {
                        'ta' => const Locale('ta'),
                        'ta_IN' => const Locale('ta', 'IN'),
                        _ => const Locale('en'),
                      };
                      ref.read(localeProvider.notifier).setLocale(locale);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'en', child: Text(l10n.langEnglish)),
                      PopupMenuItem(value: 'ta', child: Text(l10n.langTamil)),
                      PopupMenuItem(
                          value: 'ta_IN', child: Text(l10n.langMixed)),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _locationToIndex(String location) {
    if (location.startsWith('/dashboard')) return 1;
    return 0;
  }

  void _onNav(BuildContext context, int i, bool isAdmin) {
    switch (i) {
      case 0:
        context.go('/');
      case 1:
        context.go('/dashboard');
      case 2:
        if (isAdmin) context.push('/admin/create-village');
      case 3:
        if (isAdmin) context.push('/admin/create-group');
    }
  }

  String _localeKey(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
}

// ── Sync button for the NavRail trailing ─────────────────────────────────────

class _NavSyncButton extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  const _NavSyncButton({required this.l10n});

  @override
  ConsumerState<_NavSyncButton> createState() => _NavSyncButtonState();
}

class _NavSyncButtonState extends ConsumerState<_NavSyncButton> {
  bool _syncing = false;

  Future<void> _sync() async {
    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.syncNoInternet)),
        );
      }
      return;
    }

    setState(() => _syncing = true);
    final report = await ref.read(entriesProvider.notifier).sync();
    if (!mounted) return;
    setState(() => _syncing = false);

    final msg = switch (report.result) {
      SyncResult.success => widget.l10n.syncSuccessCount(report.synced),
      SyncResult.noPending => widget.l10n.nothingToSync,
      SyncResult.partialFailure => widget.l10n.syncFailedCount(report.failed),
      SyncResult.noInternet => widget.l10n.syncNoInternet,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingCountProvider);

    return Badge(
      isLabelVisible: !_syncing && pending > 0,
      label: Text('$pending'),
      child: IconButton(
        icon: _syncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync_rounded),
        tooltip: widget.l10n.syncData,
        onPressed: _syncing ? null : _sync,
      ),
    );
  }
}
