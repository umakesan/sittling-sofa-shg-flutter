import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/sync_service.dart';
import '../providers/auth_provider.dart';
import '../providers/entries_provider.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool _syncing = false;
  String? _syncMessage;
  bool _syncIsError = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final pendingCount = ref.watch(pendingCountProvider);

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              user?.role.replaceAll('_', ' ').toUpperCase() ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            decoration: const BoxDecoration(color: Color(0xFF2D6A4F)),
          ),

          // ── Sync (mobile only) ───────────────────────────────────────────
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
                      child: const Icon(Icons.sync),
                    ),
              title: Text(_syncing ? 'Syncing…' : 'Sync data'),
              subtitle: pendingCount > 0
                  ? Text('$pendingCount entr${pendingCount == 1 ? 'y' : 'ies'} pending')
                  : const Text('All entries up to date'),
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
                      color: _syncIsError
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _syncMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _syncIsError
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
          ],

          const Spacer(),

          // ── Logout ───────────────────────────────────────────────────────
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.of(context).pop(); // close drawer first
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _handleSync() async {
    // Check connectivity before attempting sync
    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (!isOnline) {
      setState(() {
        _syncMessage = 'No internet connection. Please connect and try again.';
        _syncIsError = true;
      });
      return;
    }

    setState(() {
      _syncing = true;
      _syncMessage = null;
    });

    final report = await ref.read(entriesProvider.notifier).sync();

    setState(() {
      _syncing = false;
      switch (report.result) {
        case SyncResult.success:
          _syncMessage = '${report.synced} entr${report.synced == 1 ? 'y' : 'ies'} uploaded successfully.';
          _syncIsError = false;
        case SyncResult.noPending:
          _syncMessage = 'Nothing to sync — all up to date.';
          _syncIsError = false;
        case SyncResult.partialFailure:
          _syncMessage = '${report.failed} entr${report.failed == 1 ? 'y' : 'ies'} could not be uploaded.';
          _syncIsError = true;
        case SyncResult.noInternet:
          _syncMessage = 'No internet connection. Please connect and try again.';
          _syncIsError = true;
      }
    });
  }
}
