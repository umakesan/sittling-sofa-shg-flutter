import '../api/api_client.dart';
import 'local_db.dart';

enum SyncResult { success, partialFailure, noInternet, noPending }

class SyncReport {
  final SyncResult result;
  final int synced;
  final int failed;
  final String? errorMessage;

  const SyncReport({
    required this.result,
    this.synced = 0,
    this.failed = 0,
    this.errorMessage,
  });
}

class SyncService {
  final LocalDb _db;
  final ApiClient _api;

  SyncService({required LocalDb db, required ApiClient api})
      : _db = db,
        _api = api;

  Future<SyncReport> syncPending() async {
    final pending = await _db.getPendingEntries();

    if (pending.isEmpty) {
      return const SyncReport(result: SyncResult.noPending);
    }

    int synced = 0;
    int failed = 0;
    String? lastError;

    for (final entry in pending) {
      try {
        final responseData = await _api.createEntry(entry.toApiPayload());
        final serverId = responseData['id'] as int;
        await _db.markEntrySynced(entry.localId, serverId);
        synced++;
      } catch (e) {
        failed++;
        lastError = e.toString();
      }
    }

    if (failed == 0) {
      return SyncReport(result: SyncResult.success, synced: synced);
    } else if (synced > 0) {
      return SyncReport(
        result: SyncResult.partialFailure,
        synced: synced,
        failed: failed,
        errorMessage: lastError,
      );
    } else {
      return SyncReport(
        result: SyncResult.partialFailure,
        synced: 0,
        failed: failed,
        errorMessage: lastError,
      );
    }
  }
}
