import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/group.dart';
import '../models/month_entry.dart';
import 'entries_provider.dart';
import 'groups_provider.dart';

// ─── Date helpers ─────────────────────────────────────────────────────────────

/// Number of calendar months from [from] to [to] inclusive (both "YYYY-MM-DD").
int _monthSpan(String from, String to) {
  try {
    final f = DateTime.parse(from);
    final t = DateTime.parse(to);
    return (t.year - f.year) * 12 + (t.month - f.month) + 1;
  } catch (_) {
    return 0;
  }
}

// ─── Shared nested-when helper ────────────────────────────────────────────────

AsyncValue<T> _combine<T>(
  AsyncValue<List<Group>> g,
  AsyncValue<List<MonthEntry>> e,
  T Function(List<Group>, List<MonthEntry>) fn,
) =>
    g.when(
      loading: () => const AsyncLoading(),
      error: AsyncError.new,
      data: (groups) => e.when(
        loading: () => const AsyncLoading(),
        error: AsyncError.new,
        data: (entries) => AsyncData(fn(groups, entries)),
      ),
    );

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT 2 — SOFA LOANS
// ═══════════════════════════════════════════════════════════════════════════════

class VillageSofaSummary {
  final String villageName;
  final double totalDisbursed;
  final double totalRepaid;
  final double totalInterest;
  final int groupCount;

  double get outstanding => totalDisbursed - totalRepaid;
  double get recoveryPct =>
      totalDisbursed > 0 ? (totalRepaid / totalDisbursed * 100) : 0;

  const VillageSofaSummary({
    required this.villageName,
    required this.totalDisbursed,
    required this.totalRepaid,
    required this.totalInterest,
    required this.groupCount,
  });
}

class GroupSofaSummary {
  final Group group;
  final double totalDisbursed;
  final double totalRepaid;
  final double totalInterest;
  final int entryCount;
  final String? lastEntryMonth;

  double get outstanding => totalDisbursed - totalRepaid;
  double get recoveryPct =>
      totalDisbursed > 0 ? (totalRepaid / totalDisbursed * 100) : 0;

  const GroupSofaSummary({
    required this.group,
    required this.totalDisbursed,
    required this.totalRepaid,
    required this.totalInterest,
    required this.entryCount,
    this.lastEntryMonth,
  });
}

class MonthlySofaEntry {
  final String entryMonth;
  final double disbursed;
  final double repaid;
  final double interest;

  const MonthlySofaEntry({
    required this.entryMonth,
    required this.disbursed,
    required this.repaid,
    required this.interest,
  });
}

final villageSofaSummariesProvider =
    Provider<AsyncValue<List<VillageSofaSummary>>>((ref) => _combine(
          ref.watch(groupsProvider),
          ref.watch(entriesProvider),
          _buildVillageSofa,
        ));

List<VillageSofaSummary> _buildVillageSofa(
    List<Group> groups, List<MonthEntry> entries) {
  final byVillage = <String, List<MonthEntry>>{};
  final villageByGroup = {for (final g in groups) g.id: g.villageName};
  for (final e in entries) {
    final v = villageByGroup[e.groupId];
    if (v != null && v.isNotEmpty) byVillage.putIfAbsent(v, () => []).add(e);
  }
  final names = groups
      .map((g) => g.villageName)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return names.map((v) {
    final es = byVillage[v] ?? [];
    return VillageSofaSummary(
      villageName: v,
      totalDisbursed: es.fold(0.0, (s, e) => s + e.sofaLoanDisbursed),
      totalRepaid: es.fold(0.0, (s, e) => s + e.sofaLoanRepayment),
      totalInterest: es.fold(0.0, (s, e) => s + e.sofaLoanInterestCollected),
      groupCount: groups.where((g) => g.villageName == v).length,
    );
  }).toList();
}

final groupSofaSummariesProvider =
    Provider.family<AsyncValue<List<GroupSofaSummary>>, String>(
        (ref, village) => _combine(
              ref.watch(groupsProvider),
              ref.watch(entriesProvider),
              (groups, entries) => _buildGroupSofa(
                  groups.where((g) => g.villageName == village).toList(),
                  entries),
            ));

List<GroupSofaSummary> _buildGroupSofa(
    List<Group> groups, List<MonthEntry> allEntries) {
  return groups.map((g) {
    final es = allEntries.where((e) => e.groupId == g.id).toList()
      ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));
    return GroupSofaSummary(
      group: g,
      totalDisbursed: es.fold(0.0, (s, e) => s + e.sofaLoanDisbursed),
      totalRepaid: es.fold(0.0, (s, e) => s + e.sofaLoanRepayment),
      totalInterest: es.fold(0.0, (s, e) => s + e.sofaLoanInterestCollected),
      entryCount: es.length,
      lastEntryMonth: es.isEmpty ? null : es.first.entryMonth,
    );
  }).toList();
}

final groupSofaLedgerProvider =
    Provider.family<AsyncValue<(Group?, List<MonthlySofaEntry>)>, int>(
        (ref, groupId) => _combine(
              ref.watch(groupsProvider),
              ref.watch(entriesProvider),
              (groups, entries) {
                final group =
                    groups.where((g) => g.id == groupId).firstOrNull;
                final ledger = entries
                    .where((e) => e.groupId == groupId)
                    .toList()
                  ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));
                return (
                  group,
                  ledger
                      .map((e) => MonthlySofaEntry(
                            entryMonth: e.entryMonth,
                            disbursed: e.sofaLoanDisbursed,
                            repaid: e.sofaLoanRepayment,
                            interest: e.sofaLoanInterestCollected,
                          ))
                      .toList()
                );
              },
            ));

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT 3 — BANK FLOW
// ═══════════════════════════════════════════════════════════════════════════════

class VillageBankSummary {
  final String villageName;
  final double totalDeposited;
  final double totalWithdrawn;
  final int groupCount;

  double get netFlow => totalDeposited - totalWithdrawn;

  const VillageBankSummary({
    required this.villageName,
    required this.totalDeposited,
    required this.totalWithdrawn,
    required this.groupCount,
  });
}

class GroupBankSummary {
  final Group group;
  final double totalDeposited;
  final double totalWithdrawn;
  final int entryCount;
  final String? lastEntryMonth;

  double get netFlow => totalDeposited - totalWithdrawn;

  const GroupBankSummary({
    required this.group,
    required this.totalDeposited,
    required this.totalWithdrawn,
    required this.entryCount,
    this.lastEntryMonth,
  });
}

class MonthlyBankEntry {
  final String entryMonth;
  final double deposited;
  final double withdrawn;

  double get net => deposited - withdrawn;

  const MonthlyBankEntry({
    required this.entryMonth,
    required this.deposited,
    required this.withdrawn,
  });
}

final villageBankSummariesProvider =
    Provider<AsyncValue<List<VillageBankSummary>>>((ref) => _combine(
          ref.watch(groupsProvider),
          ref.watch(entriesProvider),
          _buildVillageBank,
        ));

List<VillageBankSummary> _buildVillageBank(
    List<Group> groups, List<MonthEntry> entries) {
  final byVillage = <String, List<MonthEntry>>{};
  final villageByGroup = {for (final g in groups) g.id: g.villageName};
  for (final e in entries) {
    final v = villageByGroup[e.groupId];
    if (v != null && v.isNotEmpty) byVillage.putIfAbsent(v, () => []).add(e);
  }
  final names = groups
      .map((g) => g.villageName)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return names.map((v) {
    final es = byVillage[v] ?? [];
    return VillageBankSummary(
      villageName: v,
      totalDeposited: es.fold(0.0, (s, e) => s + e.toBank),
      totalWithdrawn: es.fold(0.0, (s, e) => s + e.fromBank),
      groupCount: groups.where((g) => g.villageName == v).length,
    );
  }).toList();
}

final groupBankSummariesProvider =
    Provider.family<AsyncValue<List<GroupBankSummary>>, String>(
        (ref, village) => _combine(
              ref.watch(groupsProvider),
              ref.watch(entriesProvider),
              (groups, entries) => _buildGroupBank(
                  groups.where((g) => g.villageName == village).toList(),
                  entries),
            ));

List<GroupBankSummary> _buildGroupBank(
    List<Group> groups, List<MonthEntry> allEntries) {
  return groups.map((g) {
    final es = allEntries.where((e) => e.groupId == g.id).toList()
      ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));
    return GroupBankSummary(
      group: g,
      totalDeposited: es.fold(0.0, (s, e) => s + e.toBank),
      totalWithdrawn: es.fold(0.0, (s, e) => s + e.fromBank),
      entryCount: es.length,
      lastEntryMonth: es.isEmpty ? null : es.first.entryMonth,
    );
  }).toList();
}

final groupBankLedgerProvider =
    Provider.family<AsyncValue<(Group?, List<MonthlyBankEntry>)>, int>(
        (ref, groupId) => _combine(
              ref.watch(groupsProvider),
              ref.watch(entriesProvider),
              (groups, entries) {
                final group =
                    groups.where((g) => g.id == groupId).firstOrNull;
                final ledger = entries
                    .where((e) => e.groupId == groupId)
                    .toList()
                  ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));
                return (
                  group,
                  ledger
                      .map((e) => MonthlyBankEntry(
                            entryMonth: e.entryMonth,
                            deposited: e.toBank,
                            withdrawn: e.fromBank,
                          ))
                      .toList()
                );
              },
            ));

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT 4 — VILLAGE COMPARE
// ═══════════════════════════════════════════════════════════════════════════════

class VillageCompareRow {
  final String villageName;
  final double savingsAsset; // savings + interest
  final double sofaOutstanding; // disbursed - repaid
  final double sofaRecoveryPct;
  final int groupCount;
  final int activeGroupCount;

  const VillageCompareRow({
    required this.villageName,
    required this.savingsAsset,
    required this.sofaOutstanding,
    required this.sofaRecoveryPct,
    required this.groupCount,
    required this.activeGroupCount,
  });
}

final villageCompareProvider =
    Provider<AsyncValue<List<VillageCompareRow>>>((ref) => _combine(
          ref.watch(groupsProvider),
          ref.watch(entriesProvider),
          _buildVillageCompare,
        ));

List<VillageCompareRow> _buildVillageCompare(
    List<Group> groups, List<MonthEntry> entries) {
  final villageByGroup = {for (final g in groups) g.id: g.villageName};
  // Latest known month (to determine "active" = entry in last 3 months)
  final allMonths = entries.map((e) => e.entryMonth).toList();
  final latestMonth =
      allMonths.isEmpty ? null : allMonths.reduce((a, b) => a.compareTo(b) > 0 ? a : b);

  final byVillage = <String, List<MonthEntry>>{};
  for (final e in entries) {
    final v = villageByGroup[e.groupId];
    if (v != null && v.isNotEmpty) byVillage.putIfAbsent(v, () => []).add(e);
  }

  final names = groups
      .map((g) => g.villageName)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  return names.map((v) {
    final es = byVillage[v] ?? [];
    final villageGroups = groups.where((g) => g.villageName == v).toList();

    final savings = es.fold(0.0, (s, e) => s + e.savingsCollected);
    final interest =
        es.fold(0.0, (s, e) => s + e.internalLoanInterestCollected);
    final sofaDisbursed = es.fold(0.0, (s, e) => s + e.sofaLoanDisbursed);
    final sofaRepaid = es.fold(0.0, (s, e) => s + e.sofaLoanRepayment);

    // Active = group has entry within 3 months of latest
    int activeCount = 0;
    if (latestMonth != null) {
      final latestDate = DateTime.parse(latestMonth);
      final cutoff = DateTime(latestDate.year, latestDate.month - 3, 1);
      for (final g in villageGroups) {
        final groupMonths = es
            .where((e) => e.groupId == g.id)
            .map((e) => e.entryMonth)
            .toList();
        if (groupMonths.any(
            (m) => !DateTime.parse(m).isBefore(cutoff))) {
          activeCount++;
        }
      }
    }

    return VillageCompareRow(
      villageName: v,
      savingsAsset: savings + interest,
      sofaOutstanding: sofaDisbursed - sofaRepaid,
      sofaRecoveryPct:
          sofaDisbursed > 0 ? (sofaRepaid / sofaDisbursed * 100) : 0,
      groupCount: villageGroups.length,
      activeGroupCount: activeCount,
    );
  }).toList();
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT 5 — OVERDUE ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

class OverdueAlert {
  final Group group;
  final String? lastEntryMonth;
  final int warningCount;
  final bool isOverdue; // no entry in last 2 months of global range

  const OverdueAlert({
    required this.group,
    this.lastEntryMonth,
    required this.warningCount,
    required this.isOverdue,
  });
}

final overdueAlertsProvider =
    Provider<AsyncValue<List<OverdueAlert>>>((ref) => _combine(
          ref.watch(groupsProvider),
          ref.watch(entriesProvider),
          _buildOverdueAlerts,
        ));

List<OverdueAlert> _buildOverdueAlerts(
    List<Group> groups, List<MonthEntry> entries) {
  if (entries.isEmpty) return [];
  final latestMonth =
      entries.map((e) => e.entryMonth).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  final latestDate = DateTime.parse(latestMonth);
  final cutoff =
      DateTime(latestDate.year, latestDate.month - 1, 1); // 2-month window

  final alerts = <OverdueAlert>[];
  for (final g in groups) {
    final groupEntries = entries.where((e) => e.groupId == g.id).toList()
      ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));
    final lastMonth =
        groupEntries.isEmpty ? null : groupEntries.first.entryMonth;
    final warningCount =
        groupEntries.where((e) => e.warningFlags.isNotEmpty).length;
    final isOverdue = lastMonth == null ||
        DateTime.parse(lastMonth).isBefore(cutoff);

    if (isOverdue || warningCount > 0) {
      alerts.add(OverdueAlert(
        group: g,
        lastEntryMonth: lastMonth,
        warningCount: warningCount,
        isOverdue: isOverdue,
      ));
    }
  }
  // Sort: overdue first, then by warning count descending
  alerts.sort((a, b) {
    if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
    return b.warningCount.compareTo(a.warningCount);
  });
  return alerts;
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT 6 — TRENDS
// ═══════════════════════════════════════════════════════════════════════════════

class MonthlyFederationTrend {
  final String entryMonth;
  final double savings;
  final double interest;
  final double sofaDisbursed;
  final double sofaRepaid;
  final int entryCount;

  double get totalAsset => savings + interest;

  const MonthlyFederationTrend({
    required this.entryMonth,
    required this.savings,
    required this.interest,
    required this.sofaDisbursed,
    required this.sofaRepaid,
    required this.entryCount,
  });
}

final trendsProvider =
    Provider<AsyncValue<List<MonthlyFederationTrend>>>((ref) => _combine(
          ref.watch(groupsProvider),
          ref.watch(entriesProvider),
          (_, entries) => _buildTrends(entries),
        ));

List<MonthlyFederationTrend> _buildTrends(List<MonthEntry> entries) {
  final byMonth = <String, List<MonthEntry>>{};
  for (final e in entries) {
    byMonth.putIfAbsent(e.entryMonth, () => []).add(e);
  }
  final months = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));
  return months.map((m) {
    final es = byMonth[m]!;
    return MonthlyFederationTrend(
      entryMonth: m,
      savings: es.fold(0.0, (s, e) => s + e.savingsCollected),
      interest: es.fold(0.0, (s, e) => s + e.internalLoanInterestCollected),
      sofaDisbursed: es.fold(0.0, (s, e) => s + e.sofaLoanDisbursed),
      sofaRepaid: es.fold(0.0, (s, e) => s + e.sofaLoanRepayment),
      entryCount: es.length,
    );
  }).toList();
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT 7 — GROUP HEALTH
// ═══════════════════════════════════════════════════════════════════════════════

class VillageHealthSummary {
  final String villageName;
  final int totalGroups;
  final int activeGroups;
  final double avgRegularityPct;
  final double totalCorpus;

  const VillageHealthSummary({
    required this.villageName,
    required this.totalGroups,
    required this.activeGroups,
    required this.avgRegularityPct,
    required this.totalCorpus,
  });
}

class GroupHealthScore {
  final Group group;
  final int expectedMonths;
  final int actualMonths;
  final double savingsCorpus;
  final String? lastEntryMonth;

  double get regularityPct =>
      expectedMonths > 0 ? (actualMonths / expectedMonths * 100) : 0;

  const GroupHealthScore({
    required this.group,
    required this.expectedMonths,
    required this.actualMonths,
    required this.savingsCorpus,
    this.lastEntryMonth,
  });
}

final villageHealthProvider =
    Provider<AsyncValue<List<VillageHealthSummary>>>((ref) => _combine(
          ref.watch(groupsProvider),
          ref.watch(entriesProvider),
          _buildVillageHealth,
        ));

List<VillageHealthSummary> _buildVillageHealth(
    List<Group> groups, List<MonthEntry> entries) {
  if (entries.isEmpty) return [];
  final globalMin = entries.map((e) => e.entryMonth).reduce((a, b) => a.compareTo(b) < 0 ? a : b);
  final globalMax = entries.map((e) => e.entryMonth).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  final expectedMonths = _monthSpan(globalMin, globalMax);
  final latestDate = DateTime.parse(globalMax);
  final cutoff = DateTime(latestDate.year, latestDate.month - 3, 1);

  final byVillage = <String, List<Group>>{};
  for (final g in groups) {
    if (g.villageName.isNotEmpty) {
      byVillage.putIfAbsent(g.villageName, () => []).add(g);
    }
  }
  final names = byVillage.keys.toList()..sort();

  return names.map((v) {
    final villageGroups = byVillage[v]!;
    double totalCorpus = 0;
    double totalRegularity = 0;
    int activeCount = 0;

    for (final g in villageGroups) {
      final gEntries =
          entries.where((e) => e.groupId == g.id).toList();
      final actual = gEntries.map((e) => e.entryMonth).toSet().length;
      totalCorpus += gEntries.fold(
          0.0, (s, e) => s + e.savingsCollected + e.internalLoanInterestCollected);
      totalRegularity +=
          expectedMonths > 0 ? (actual / expectedMonths * 100) : 0;
      if (gEntries.any(
          (e) => !DateTime.parse(e.entryMonth).isBefore(cutoff))) {
        activeCount++;
      }
    }

    return VillageHealthSummary(
      villageName: v,
      totalGroups: villageGroups.length,
      activeGroups: activeCount,
      avgRegularityPct: villageGroups.isEmpty
          ? 0
          : totalRegularity / villageGroups.length,
      totalCorpus: totalCorpus,
    );
  }).toList();
}

final groupHealthScoresProvider =
    Provider.family<AsyncValue<List<GroupHealthScore>>, String>(
        (ref, village) => _combine(
              ref.watch(groupsProvider),
              ref.watch(entriesProvider),
              (groups, entries) {
                if (entries.isEmpty) return [];
                final globalMin = entries.map((e) => e.entryMonth).reduce(
                    (a, b) => a.compareTo(b) < 0 ? a : b);
                final globalMax = entries.map((e) => e.entryMonth).reduce(
                    (a, b) => a.compareTo(b) > 0 ? a : b);
                final expected = _monthSpan(globalMin, globalMax);
                return _buildGroupHealth(
                    groups.where((g) => g.villageName == village).toList(),
                    entries,
                    expected);
              },
            ));

List<GroupHealthScore> _buildGroupHealth(
    List<Group> groups, List<MonthEntry> allEntries, int expectedMonths) {
  return groups.map((g) {
    final es = allEntries.where((e) => e.groupId == g.id).toList()
      ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));
    final actual = es.map((e) => e.entryMonth).toSet().length;
    final corpus = es.fold(0.0,
        (s, e) => s + e.savingsCollected + e.internalLoanInterestCollected);
    return GroupHealthScore(
      group: g,
      expectedMonths: expectedMonths,
      actualMonths: actual,
      savingsCorpus: corpus,
      lastEntryMonth: es.isEmpty ? null : es.first.entryMonth,
    );
  }).toList();
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT 8 — RECOVERY RATE
// ═══════════════════════════════════════════════════════════════════════════════

class VillageRecoverySummary {
  final String villageName;
  final double totalDisbursed;
  final double totalRepaid;
  final int groupCount;

  double get outstanding => totalDisbursed - totalRepaid;
  double get recoveryPct =>
      totalDisbursed > 0 ? (totalRepaid / totalDisbursed * 100) : 0;

  const VillageRecoverySummary({
    required this.villageName,
    required this.totalDisbursed,
    required this.totalRepaid,
    required this.groupCount,
  });
}

class GroupRecoverySummary {
  final Group group;
  final double disbursed;
  final double repaid;
  final int entryCount;

  double get outstanding => disbursed - repaid;
  double get recoveryPct =>
      disbursed > 0 ? (repaid / disbursed * 100) : 0;

  const GroupRecoverySummary({
    required this.group,
    required this.disbursed,
    required this.repaid,
    required this.entryCount,
  });
}

final villageRecoveryProvider =
    Provider<AsyncValue<List<VillageRecoverySummary>>>((ref) => _combine(
          ref.watch(groupsProvider),
          ref.watch(entriesProvider),
          _buildVillageRecovery,
        ));

List<VillageRecoverySummary> _buildVillageRecovery(
    List<Group> groups, List<MonthEntry> entries) {
  final byVillage = <String, List<MonthEntry>>{};
  final villageByGroup = {for (final g in groups) g.id: g.villageName};
  for (final e in entries) {
    final v = villageByGroup[e.groupId];
    if (v != null && v.isNotEmpty) byVillage.putIfAbsent(v, () => []).add(e);
  }
  final names = groups
      .map((g) => g.villageName)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return names.map((v) {
    final es = byVillage[v] ?? [];
    return VillageRecoverySummary(
      villageName: v,
      totalDisbursed: es.fold(0.0, (s, e) => s + e.sofaLoanDisbursed),
      totalRepaid: es.fold(0.0, (s, e) => s + e.sofaLoanRepayment),
      groupCount: groups.where((g) => g.villageName == v).length,
    );
  }).toList();
}

final groupRecoveryProvider =
    Provider.family<AsyncValue<List<GroupRecoverySummary>>, String>(
        (ref, village) => _combine(
              ref.watch(groupsProvider),
              ref.watch(entriesProvider),
              (groups, entries) => _buildGroupRecovery(
                  groups.where((g) => g.villageName == village).toList(),
                  entries),
            ));

List<GroupRecoverySummary> _buildGroupRecovery(
    List<Group> groups, List<MonthEntry> allEntries) {
  return groups.map((g) {
    final es = allEntries.where((e) => e.groupId == g.id).toList();
    return GroupRecoverySummary(
      group: g,
      disbursed: es.fold(0.0, (s, e) => s + e.sofaLoanDisbursed),
      repaid: es.fold(0.0, (s, e) => s + e.sofaLoanRepayment),
      entryCount: es.length,
    );
  }).toList();
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPORT 9 — AUDIT LOG
// ═══════════════════════════════════════════════════════════════════════════════

class VillageAuditSummary {
  final String villageName;
  final int totalGroups;
  final int pendingEntries;
  final int warningEntries;
  final int totalMissingMonths;

  const VillageAuditSummary({
    required this.villageName,
    required this.totalGroups,
    required this.pendingEntries,
    required this.warningEntries,
    required this.totalMissingMonths,
  });
}

class GroupAuditRecord {
  final Group group;
  final String? lastEntryMonth;
  final int totalEntries;
  final int pendingSync;
  final int warningCount;
  final int missingMonths;
  final DateTime? lastUpdated;

  const GroupAuditRecord({
    required this.group,
    this.lastEntryMonth,
    required this.totalEntries,
    required this.pendingSync,
    required this.warningCount,
    required this.missingMonths,
    this.lastUpdated,
  });
}

final villageAuditProvider =
    Provider<AsyncValue<List<VillageAuditSummary>>>((ref) => _combine(
          ref.watch(groupsProvider),
          ref.watch(entriesProvider),
          _buildVillageAudit,
        ));

List<VillageAuditSummary> _buildVillageAudit(
    List<Group> groups, List<MonthEntry> entries) {
  if (entries.isEmpty) return [];
  final globalMin = entries.map((e) => e.entryMonth).reduce((a, b) => a.compareTo(b) < 0 ? a : b);
  final globalMax = entries.map((e) => e.entryMonth).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  final expectedMonths = _monthSpan(globalMin, globalMax);

  final byVillage = <String, List<MonthEntry>>{};
  final villageByGroup = {for (final g in groups) g.id: g.villageName};
  for (final e in entries) {
    final v = villageByGroup[e.groupId];
    if (v != null && v.isNotEmpty) byVillage.putIfAbsent(v, () => []).add(e);
  }
  final names = groups
      .map((g) => g.villageName)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return names.map((v) {
    final es = byVillage[v] ?? [];
    final villageGroups = groups.where((g) => g.villageName == v);
    int totalMissing = 0;
    for (final g in villageGroups) {
      final actual =
          es.where((e) => e.groupId == g.id).map((e) => e.entryMonth).toSet().length;
      totalMissing += (expectedMonths - actual).clamp(0, expectedMonths);
    }
    return VillageAuditSummary(
      villageName: v,
      totalGroups: villageGroups.length,
      pendingEntries:
          es.where((e) => e.syncStatus == SyncStatus.pendingSync).length,
      warningEntries: es.where((e) => e.warningFlags.isNotEmpty).length,
      totalMissingMonths: totalMissing,
    );
  }).toList();
}

final groupAuditProvider =
    Provider.family<AsyncValue<List<GroupAuditRecord>>, String>(
        (ref, village) => _combine(
              ref.watch(groupsProvider),
              ref.watch(entriesProvider),
              (groups, entries) {
                if (entries.isEmpty) return [];
                final globalMin = entries.map((e) => e.entryMonth).reduce(
                    (a, b) => a.compareTo(b) < 0 ? a : b);
                final globalMax = entries.map((e) => e.entryMonth).reduce(
                    (a, b) => a.compareTo(b) > 0 ? a : b);
                final expected = _monthSpan(globalMin, globalMax);
                return _buildGroupAudit(
                    groups.where((g) => g.villageName == village).toList(),
                    entries,
                    expected);
              },
            ));

List<GroupAuditRecord> _buildGroupAudit(
    List<Group> groups, List<MonthEntry> allEntries, int expectedMonths) {
  return groups.map((g) {
    final es = allEntries.where((e) => e.groupId == g.id).toList()
      ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));
    final actual = es.map((e) => e.entryMonth).toSet().length;
    final missing = (expectedMonths - actual).clamp(0, expectedMonths);
    return GroupAuditRecord(
      group: g,
      lastEntryMonth: es.isEmpty ? null : es.first.entryMonth,
      totalEntries: es.length,
      pendingSync:
          es.where((e) => e.syncStatus == SyncStatus.pendingSync).length,
      warningCount: es.where((e) => e.warningFlags.isNotEmpty).length,
      missingMonths: missing,
      lastUpdated: es.isEmpty ? null : es.first.updatedAt,
    );
  }).toList();
}
