import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/sync_service.dart';
import '../providers/entries_provider.dart';

class SyncButton extends ConsumerStatefulWidget {
  const SyncButton({super.key});

  @override
  ConsumerState<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends ConsumerState<SyncButton> {
  bool _syncing = false;
  String? _lastResult;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    final pendingCount = ref.watch(pendingCountProvider);

    final label = pendingCount > 0
        ? 'Sync ($pendingCount pending)'
        : 'Sync (up to date)';

    return Column(
      children: [
        FilledButton.icon(
          onPressed: _syncing ? null : _doSync,
          icon: _syncing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.sync),
          label: Text(_syncing ? 'Syncing…' : label),
          style: FilledButton.styleFrom(
            backgroundColor:
                pendingCount > 0 ? const Color(0xFF2D6A4F) : Colors.grey,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        if (_lastResult != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _lastResult!,
              style: TextStyle(
                fontSize: 12,
                color: _lastResult!.startsWith('Sync failed')
                    ? Colors.red
                    : Colors.green.shade700,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _doSync() async {
    setState(() {
      _syncing = true;
      _lastResult = null;
    });

    final report = await ref.read(entriesProvider.notifier).sync();

    setState(() {
      _syncing = false;
      _lastResult = switch (report.result) {
        SyncResult.success =>
          'Last synced: ${_timeNow()} — ${report.synced} uploaded',
        SyncResult.noPending => 'Nothing to sync',
        SyncResult.partialFailure =>
          'Sync failed — ${report.failed} entries could not be uploaded',
        SyncResult.noInternet => 'Sync failed — check internet connection',
      };
    });
  }

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return 'Today $h:$m $ampm';
  }
}
