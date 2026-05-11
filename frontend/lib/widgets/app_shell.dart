import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shg_portal/l10n/app_localizations.dart';

import '../providers/locale_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return child;

    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = location.startsWith('/dashboard') ? 1 : 0;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) {
              if (i == 0) {
                context.go('/');
              } else {
                context.go('/dashboard');
              }
            },
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
            ],
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PopupMenuButton<String>(
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
                  PopupMenuItem(
                    value: 'en',
                    child: Text(l10n.langEnglish),
                  ),
                  PopupMenuItem(
                    value: 'ta',
                    child: Text(l10n.langTamil),
                  ),
                  PopupMenuItem(
                    value: 'ta_IN',
                    child: Text(l10n.langMixed),
                  ),
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

  String _localeKey(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
}
