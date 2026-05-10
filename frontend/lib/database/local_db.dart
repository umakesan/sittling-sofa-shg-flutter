import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/group.dart';
import '../models/month_entry.dart';

part 'local_db.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

class GroupsTable extends Table {
  @override
  String get tableName => 'groups';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get villageName => text().named('village_name')();
  TextColumn get code => text()();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class MonthEntriesTable extends Table {
  @override
  String get tableName => 'month_entries';

  // UUID generated on device — primary key
  TextColumn get localId => text().named('local_id')();
  IntColumn get serverId => integer().named('server_id').nullable()();
  IntColumn get groupId => integer().named('group_id')();
  TextColumn get entryMonth => text().named('entry_month')();
  TextColumn get entryMode => text().named('entry_mode').withDefault(const Constant('manual'))();
  RealColumn get savingsCollected =>
      real().named('savings_collected').withDefault(const Constant(0))();
  RealColumn get internalLoanPrincipalDisbursed =>
      real().named('internal_loan_principal_disbursed').withDefault(const Constant(0))();
  RealColumn get internalLoanInterestCollected =>
      real().named('internal_loan_interest_collected').withDefault(const Constant(0))();
  RealColumn get toBank => real().named('to_bank').withDefault(const Constant(0))();
  RealColumn get fromBank => real().named('from_bank').withDefault(const Constant(0))();
  RealColumn get sofaLoanDisbursed =>
      real().named('sofa_loan_disbursed').withDefault(const Constant(0))();
  RealColumn get sofaLoanRepayment =>
      real().named('sofa_loan_repayment').withDefault(const Constant(0))();
  RealColumn get sofaLoanInterestCollected =>
      real().named('sofa_loan_interest_collected').withDefault(const Constant(0))();
  TextColumn get notes => text().named('notes').nullable()();
  // Stored as JSON string: '["flag1","flag2"]'
  TextColumn get warningFlags =>
      text().named('warning_flags').withDefault(const Constant('[]'))();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending_sync'))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {localId};
}

// ---------------------------------------------------------------------------
// Database class
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [GroupsTable, MonthEntriesTable])
class LocalDb extends _$LocalDb {
  LocalDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // -- Groups --

  Future<void> upsertGroups(List<Group> groups) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        groupsTable,
        groups.map(
          (g) => GroupsTableCompanion.insert(
            id: Value(g.id),
            name: g.name,
            villageName: g.villageName,
            code: g.code,
            isActive: Value(g.isActive),
          ),
        ),
      );
    });
  }

  Future<List<Group>> getGroups() async {
    final rows = await select(groupsTable).get();
    return rows
        .map((r) => Group(
              id: r.id,
              name: r.name,
              villageName: r.villageName,
              code: r.code,
              isActive: r.isActive,
            ))
        .toList();
  }

  // -- Month Entries --

  Future<void> insertEntry(MonthEntry entry) async {
    await into(monthEntriesTable).insert(
      MonthEntriesTableCompanion.insert(
        localId: entry.localId,
        serverId: Value(entry.serverId),
        groupId: entry.groupId,
        entryMonth: entry.entryMonth,
        entryMode: Value(entry.entryMode.name),
        savingsCollected: Value(entry.savingsCollected),
        internalLoanPrincipalDisbursed: Value(entry.internalLoanPrincipalDisbursed),
        internalLoanInterestCollected: Value(entry.internalLoanInterestCollected),
        toBank: Value(entry.toBank),
        fromBank: Value(entry.fromBank),
        sofaLoanDisbursed: Value(entry.sofaLoanDisbursed),
        sofaLoanRepayment: Value(entry.sofaLoanRepayment),
        sofaLoanInterestCollected: Value(entry.sofaLoanInterestCollected),
        notes: Value(entry.notes),
        warningFlags: Value(jsonEncode(entry.warningFlags)),
        syncStatus: Value(entry.syncStatus.name == 'pendingSync' ? 'pending_sync' : 'synced'),
        createdAt: entry.createdAt.toIso8601String(),
        updatedAt: entry.updatedAt.toIso8601String(),
      ),
    );
  }

  Future<void> markEntrySynced(String localId, int serverId) async {
    await (update(monthEntriesTable)..where((t) => t.localId.equals(localId))).write(
      MonthEntriesTableCompanion(
        serverId: Value(serverId),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<List<MonthEntry>> getAllEntries() async {
    final rows = await select(monthEntriesTable).get();
    return rows.map(_rowToEntry).toList();
  }

  Future<List<MonthEntry>> getPendingEntries() async {
    final rows = await (select(monthEntriesTable)
          ..where((t) => t.syncStatus.equals('pending_sync')))
        .get();
    return rows.map(_rowToEntry).toList();
  }

  Future<void> updateEntry(MonthEntry entry) async {
    await (update(monthEntriesTable)..where((t) => t.localId.equals(entry.localId))).write(
      MonthEntriesTableCompanion(
        savingsCollected: Value(entry.savingsCollected),
        internalLoanPrincipalDisbursed: Value(entry.internalLoanPrincipalDisbursed),
        internalLoanInterestCollected: Value(entry.internalLoanInterestCollected),
        toBank: Value(entry.toBank),
        fromBank: Value(entry.fromBank),
        sofaLoanDisbursed: Value(entry.sofaLoanDisbursed),
        sofaLoanRepayment: Value(entry.sofaLoanRepayment),
        sofaLoanInterestCollected: Value(entry.sofaLoanInterestCollected),
        notes: Value(entry.notes),
        warningFlags: Value(jsonEncode(entry.warningFlags)),
        syncStatus: const Value('pending_sync'),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  MonthEntry _rowToEntry(MonthEntriesTableData r) => MonthEntry(
        localId: r.localId,
        serverId: r.serverId,
        groupId: r.groupId,
        entryMonth: r.entryMonth,
        entryMode: r.entryMode == 'prefill' ? EntryMode.prefill : EntryMode.manual,
        savingsCollected: r.savingsCollected,
        internalLoanPrincipalDisbursed: r.internalLoanPrincipalDisbursed,
        internalLoanInterestCollected: r.internalLoanInterestCollected,
        toBank: r.toBank,
        fromBank: r.fromBank,
        sofaLoanDisbursed: r.sofaLoanDisbursed,
        sofaLoanRepayment: r.sofaLoanRepayment,
        sofaLoanInterestCollected: r.sofaLoanInterestCollected,
        notes: r.notes,
        warningFlags: List<String>.from(jsonDecode(r.warningFlags) as List),
        syncStatus: r.syncStatus == 'synced' ? SyncStatus.synced : SyncStatus.pendingSync,
        createdAt: DateTime.parse(r.createdAt),
        updatedAt: DateTime.parse(r.updatedAt),
      );
}

// Opens SQLite on mobile, IndexedDB on web — drift handles this automatically
QueryExecutor _openConnection() {
  return driftDatabase(name: 'shg_portal');
}
