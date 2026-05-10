import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/sync_service.dart';
import '../models/month_entry.dart';
import 'shared_providers.dart';

class EntriesNotifier extends AsyncNotifier<List<MonthEntry>> {
  @override
  Future<List<MonthEntry>> build() async {
    final db = ref.read(localDbProvider);
    return db.getAllEntries();
  }

  Future<MonthEntry> createEntry({
    required int groupId,
    required String entryMonth,
    required EntryMode entryMode,
    double savingsCollected = 0,
    double internalLoanPrincipalDisbursed = 0,
    double internalLoanInterestCollected = 0,
    double toBank = 0,
    double fromBank = 0,
    double sofaLoanDisbursed = 0,
    double sofaLoanRepayment = 0,
    double sofaLoanInterestCollected = 0,
    String? notes,
  }) async {
    final db = ref.read(localDbProvider);
    final now = DateTime.now();
    final entry = MonthEntry(
      localId: const Uuid().v4(),
      groupId: groupId,
      entryMonth: entryMonth,
      entryMode: entryMode,
      savingsCollected: savingsCollected,
      internalLoanPrincipalDisbursed: internalLoanPrincipalDisbursed,
      internalLoanInterestCollected: internalLoanInterestCollected,
      toBank: toBank,
      fromBank: fromBank,
      sofaLoanDisbursed: sofaLoanDisbursed,
      sofaLoanRepayment: sofaLoanRepayment,
      sofaLoanInterestCollected: sofaLoanInterestCollected,
      notes: notes,
      warningFlags: _buildWarnings(
        savingsCollected: savingsCollected,
        internalLoanInterestCollected: internalLoanInterestCollected,
        toBank: toBank,
        fromBank: fromBank,
      ),
      createdAt: now,
      updatedAt: now,
    );
    await db.insertEntry(entry);
    ref.invalidateSelf();
    return entry;
  }

  Future<void> updateEntry(MonthEntry entry) async {
    final db = ref.read(localDbProvider);
    final updated = entry.copyWith(
      warningFlags: _buildWarnings(
        savingsCollected: entry.savingsCollected,
        internalLoanInterestCollected: entry.internalLoanInterestCollected,
        toBank: entry.toBank,
        fromBank: entry.fromBank,
      ),
      updatedAt: DateTime.now(),
    );
    await db.updateEntry(updated);
    ref.invalidateSelf();
  }

  Future<SyncReport> sync() async {
    final db = ref.read(localDbProvider);
    final api = ref.read(apiClientProvider);
    final service = SyncService(db: db, api: api);
    final report = await service.syncPending();
    if (report.synced > 0) ref.invalidateSelf();
    return report;
  }

  // Mirrors backend/app/services/validation.py
  List<String> _buildWarnings({
    required double savingsCollected,
    required double internalLoanInterestCollected,
    required double toBank,
    required double fromBank,
  }) {
    final warnings = <String>[];
    if (toBank > savingsCollected + internalLoanInterestCollected + 1) {
      warnings.add('To bank exceeds visible collections. Check the figures.');
    }
    if (fromBank > 0 && toBank == 0) {
      warnings.add('Bank withdrawal present with no deposit this month.');
    }
    return warnings;
  }
}

final entriesProvider =
    AsyncNotifierProvider<EntriesNotifier, List<MonthEntry>>(EntriesNotifier.new);

final pendingCountProvider = Provider<int>((ref) {
  final entries = ref.watch(entriesProvider);
  return entries.maybeWhen(
    data: (list) =>
        list.where((e) => e.syncStatus == SyncStatus.pendingSync).length,
    orElse: () => 0,
  );
});
