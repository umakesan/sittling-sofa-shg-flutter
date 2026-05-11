import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/sync_service.dart';
import '../providers/auth_provider.dart';
import '../providers/entries_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool _syncing = false;
  String? _syncMessage;
  bool _syncIsError = false;
  late AppLocalizations _l10n;

  @override
  Widget build(BuildContext context) {
    _l10n = AppLocalizations.of(context);
    final user = ref.watch(authProvider);
    final pendingCount = ref.watch(pendingCountProvider);
    final currentLocale = ref.watch(localeProvider);

    return Drawer(
      backgroundColor: AppColors.surfaceCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 26,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.textOnDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.role.replaceAll('_', ' ').toUpperCase() ?? '',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textOnDarkMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'SOFA',
                    style: AppTextStyles.badge.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Language switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_l10n.language, style: AppTextStyles.sectionHeader),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'en',
                      label: Text(_l10n.langEnglish,
                          style: AppTextStyles.label),
                    ),
                    ButtonSegment(
                      value: 'ta',
                      label: Text(_l10n.langTamil,
                          style: AppTextStyles.label),
                    ),
                    ButtonSegment(
                      value: 'ta_IN',
                      label: Text(_l10n.langMixed,
                          style: AppTextStyles.label),
                    ),
                  ],
                  selected: {_localeKey(currentLocale)},
                  onSelectionChanged: (Set<String> sel) {
                    final locale = switch (sel.first) {
                      'ta' => const Locale('ta'),
                      'ta_IN' => const Locale('ta', 'IN'),
                      _ => const Locale('en'),
                    };
                    ref.read(localeProvider.notifier).setLocale(locale);
                  },
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(AppTextStyles.label),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Sync (mobile only)
          if (!kIsWeb) ...[
            ListTile(
              leading: _syncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Badge(
                      isLabelVisible: pendingCount > 0,
                      label: Text('$pendingCount'),
                      child: Icon(Icons.sync,
                          color: pendingCount > 0
                              ? AppColors.pending
                              : AppColors.textSecondary),
                    ),
              title: Text(
                _syncing ? _l10n.syncing : _l10n.syncData,
                style: AppTextStyles.body,
              ),
              subtitle: Text(
                pendingCount > 0
                    ? _l10n.pendingCount(pendingCount)
                    : _l10n.allEntriesUpToDate,
                style: AppTextStyles.label,
              ),
              enabled: !_syncing,
              onTap: _handleSync,
            ),
            if (_syncMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      _syncIsError ? Icons.warning_amber : Icons.check_circle,
                      size: 14,
                      color: _syncIsError ? AppColors.warning : AppColors.synced,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _syncMessage!,
                        style: AppTextStyles.label.copyWith(
                          color:
                              _syncIsError ? AppColors.warning : AppColors.synced,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
          ],


          const Spacer(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(_l10n.logout,
                style: AppTextStyles.body.copyWith(color: AppColors.error)),
            onTap: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 8),
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

  Future<void> _handleSync() async {
    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (!isOnline) {
      setState(() {
        _syncMessage = _l10n.syncNoInternet;
        _syncIsError = true;
      });
      return;
    }

    setState(() {
      _syncing = true;
      _syncMessage = null;
    });

    final report = await ref.read(entriesProvider.notifier).sync();

    if (!mounted) return;
    setState(() {
      _syncing = false;
      switch (report.result) {
        case SyncResult.success:
          _syncMessage = _l10n.syncSuccessCount(report.synced);
          _syncIsError = false;
        case SyncResult.noPending:
          _syncMessage = _l10n.nothingToSync;
          _syncIsError = false;
        case SyncResult.partialFailure:
          _syncMessage = _l10n.syncFailedCount(report.failed);
          _syncIsError = true;
        case SyncResult.noInternet:
          _syncMessage = _l10n.syncNoInternet;
          _syncIsError = true;
      }
    });
  }
}
