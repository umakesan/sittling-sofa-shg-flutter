import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../database/local_db.dart';
import '../database/sync_service.dart';
import '../models/month_entry.dart';

abstract interface class EntryRepository {
  Future<List<MonthEntry>> getAll();
  Future<MonthEntry> insert(MonthEntry entry);
  Future<MonthEntry> update(MonthEntry entry);
  Future<SyncReport> sync();
}

// Native: write locally first, sync to server on demand.
class LocalEntryRepository implements EntryRepository {
  LocalEntryRepository({required LocalDb db, required ApiClient api})
      : _db = db,
        _api = api;

  final LocalDb _db;
  final ApiClient _api;

  @override
  Future<List<MonthEntry>> getAll() => _db.getAllEntries();

  @override
  Future<MonthEntry> insert(MonthEntry entry) async {
    await _db.insertEntry(entry);
    return entry;
  }

  @override
  Future<MonthEntry> update(MonthEntry entry) async {
    await _db.updateEntry(entry);
    return entry;
  }

  @override
  Future<SyncReport> sync() => SyncService(db: _db, api: _api).syncPending();
}

// Web: every operation hits the API immediately, no local cache.
class ApiEntryRepository implements EntryRepository {
  ApiEntryRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<List<MonthEntry>> getAll() async {
    final data = await _api.fetchEntries();
    return data.map(_fromJson).toList();
  }

  @override
  Future<MonthEntry> insert(MonthEntry entry) async {
    final json = await _api.createEntry(entry.toApiPayload());
    return _fromJson(json);
  }

  @override
  Future<MonthEntry> update(MonthEntry entry) async {
    final json = await _api.updateEntry(entry.serverId!, entry.toApiPayload());
    return _fromJson(json);
  }

  @override
  Future<SyncReport> sync() async =>
      const SyncReport(result: SyncResult.noPending);

  MonthEntry _fromJson(Map<String, dynamic> json) => MonthEntry(
        localId: const Uuid().v4(),
        serverId: json['id'] as int,
        groupId: json['group_id'] as int,
        entryMonth: json['entry_month'] as String,
        entryMode: json['entry_mode'] == 'prefill'
            ? EntryMode.prefill
            : EntryMode.manual,
        savingsCollected: (json['savings_collected'] as num).toDouble(),
        internalLoanPrincipalDisbursed:
            (json['internal_loan_principal_disbursed'] as num).toDouble(),
        internalLoanInterestCollected:
            (json['internal_loan_interest_collected'] as num).toDouble(),
        toBank: (json['to_bank'] as num).toDouble(),
        fromBank: (json['from_bank'] as num).toDouble(),
        sofaLoanDisbursed: (json['sofa_loan_disbursed'] as num).toDouble(),
        sofaLoanRepayment: (json['sofa_loan_repayment'] as num).toDouble(),
        sofaLoanInterestCollected:
            (json['sofa_loan_interest_collected'] as num).toDouble(),
        notes: json['notes'] as String?,
        warningFlags: (json['warning_flags'] as List).cast<String>(),
        syncStatus: SyncStatus.synced,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}
