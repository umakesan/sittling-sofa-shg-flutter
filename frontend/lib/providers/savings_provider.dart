import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/group.dart';
import '../models/month_entry.dart';
import 'entries_provider.dart';
import 'groups_provider.dart';

// ─── Data models ─────────────────────────────────────────────────────────────

class VillageSavingsSummary {
  final String villageName;
  final double totalSavings;
  final double totalInterest;
  final int groupCount;
  final double? momChange; // null = no prior month to compare

  double get totalAsset => totalSavings + totalInterest;

  const VillageSavingsSummary({
    required this.villageName,
    required this.totalSavings,
    required this.totalInterest,
    required this.groupCount,
    this.momChange,
  });
}

class GroupSavingsSummary {
  final Group group;
  final double totalSavings;
  final double totalInterest;
  final int entryCount;
  final String? lastEntryMonth; // "YYYY-MM-DD"
  final double? momChange;

  double get totalAsset => totalSavings + totalInterest;

  const GroupSavingsSummary({
    required this.group,
    required this.totalSavings,
    required this.totalInterest,
    required this.entryCount,
    this.lastEntryMonth,
    this.momChange,
  });
}

class MonthlySavingsEntry {
  final String entryMonth; // "YYYY-MM-DD"
  final double savings;
  final double interest;

  double get total => savings + interest;

  const MonthlySavingsEntry({
    required this.entryMonth,
    required this.savings,
    required this.interest,
  });
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Returns the "YYYY-MM-01" string for the month prior to [yearMonthDay].
String? _prevMonthOf(String yearMonthDay) {
  try {
    final d = DateTime.parse(yearMonthDay);
    final prev = DateTime(d.year, d.month - 1, 1);
    return DateFormat('yyyy-MM-dd').format(prev);
  } catch (_) {
    return null;
  }
}

// ─── Federation-level ────────────────────────────────────────────────────────

/// All villages with their aggregated savings summaries, sorted by name.
final villageSavingsSummariesProvider =
    Provider<AsyncValue<List<VillageSavingsSummary>>>((ref) {
  final groupsAsync = ref.watch(groupsProvider);
  final entriesAsync = ref.watch(entriesProvider);

  return groupsAsync.when(
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
    data: (groups) => entriesAsync.when(
      loading: () => const AsyncLoading(),
      error: AsyncError.new,
      data: (entries) => AsyncData(_buildVillageSummaries(groups, entries)),
    ),
  );
});

List<VillageSavingsSummary> _buildVillageSummaries(
  List<Group> groups,
  List<MonthEntry> entries,
) {
  // Build lookup: groupId → villageName
  final Map<int, String> villageByGroupId = {
    for (final g in groups) g.id: g.villageName,
  };

  // Bucket entries by village
  final Map<String, List<MonthEntry>> byVillage = {};
  for (final e in entries) {
    final village = villageByGroupId[e.groupId];
    if (village != null && village.isNotEmpty) {
      byVillage.putIfAbsent(village, () => []).add(e);
    }
  }

  // Collect unique village names from groups
  final villageNames = groups
      .map((g) => g.villageName)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  return villageNames.map((village) {
    final villageEntries = byVillage[village] ?? [];

    double totalSavings = 0;
    double totalInterest = 0;
    for (final e in villageEntries) {
      totalSavings += e.savingsCollected;
      totalInterest += e.internalLoanInterestCollected;
    }

    // MoM: compare last month's total savings vs. the month before it
    double? momChange;
    if (villageEntries.isNotEmpty) {
      final sortedMonths = villageEntries
          .map((e) => e.entryMonth)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (sortedMonths.isNotEmpty) {
        final lastMonth = sortedMonths.first;
        final prevMonth = _prevMonthOf(lastMonth);

        final lastTotal = villageEntries
            .where((e) => e.entryMonth == lastMonth)
            .fold(0.0, (s, e) => s + e.savingsCollected);

        if (prevMonth != null) {
          final prevTotal = villageEntries
              .where((e) => e.entryMonth == prevMonth)
              .fold(0.0, (s, e) => s + e.savingsCollected);
          if (prevTotal > 0) momChange = lastTotal - prevTotal;
        }
      }
    }

    final groupCount =
        groups.where((g) => g.villageName == village).length;

    return VillageSavingsSummary(
      villageName: village,
      totalSavings: totalSavings,
      totalInterest: totalInterest,
      groupCount: groupCount,
      momChange: momChange,
    );
  }).toList();
}

// ─── Village-level ───────────────────────────────────────────────────────────

/// All groups in [villageName] with their savings summaries.
final groupSavingsSummariesProvider = Provider.family<
    AsyncValue<List<GroupSavingsSummary>>, String>((ref, villageName) {
  final groupsAsync = ref.watch(groupsProvider);
  final entriesAsync = ref.watch(entriesProvider);

  return groupsAsync.when(
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
    data: (groups) => entriesAsync.when(
      loading: () => const AsyncLoading(),
      error: AsyncError.new,
      data: (entries) => AsyncData(
        _buildGroupSummaries(
          groups.where((g) => g.villageName == villageName).toList(),
          entries,
        ),
      ),
    ),
  );
});

List<GroupSavingsSummary> _buildGroupSummaries(
  List<Group> groups,
  List<MonthEntry> allEntries,
) {
  return groups.map((group) {
    final groupEntries = allEntries
        .where((e) => e.groupId == group.id)
        .toList()
      ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));

    double totalSavings = 0;
    double totalInterest = 0;
    for (final e in groupEntries) {
      totalSavings += e.savingsCollected;
      totalInterest += e.internalLoanInterestCollected;
    }

    String? lastEntryMonth;
    double? momChange;

    if (groupEntries.isNotEmpty) {
      lastEntryMonth = groupEntries.first.entryMonth;
      final prevMonth = _prevMonthOf(lastEntryMonth);
      if (prevMonth != null) {
        final prevEntry = groupEntries
            .where((e) => e.entryMonth == prevMonth)
            .firstOrNull;
        if (prevEntry != null) {
          momChange = groupEntries.first.savingsCollected -
              prevEntry.savingsCollected;
        }
      }
    }

    return GroupSavingsSummary(
      group: group,
      totalSavings: totalSavings,
      totalInterest: totalInterest,
      entryCount: groupEntries.length,
      lastEntryMonth: lastEntryMonth,
      momChange: momChange,
    );
  }).toList();
}

// ─── Group-level ─────────────────────────────────────────────────────────────

/// Monthly savings ledger for a single group, newest first.
final groupSavingsLedgerProvider = Provider.family<
    AsyncValue<(Group?, List<MonthlySavingsEntry>)>, int>((ref, groupId) {
  final groupsAsync = ref.watch(groupsProvider);
  final entriesAsync = ref.watch(entriesProvider);

  return groupsAsync.when(
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
    data: (groups) => entriesAsync.when(
      loading: () => const AsyncLoading(),
      error: AsyncError.new,
      data: (entries) {
        final group = groups.where((g) => g.id == groupId).firstOrNull;
        final ledger = entries
            .where((e) => e.groupId == groupId)
            .toList()
          ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));

        final monthlyEntries = ledger
            .map((e) => MonthlySavingsEntry(
                  entryMonth: e.entryMonth,
                  savings: e.savingsCollected,
                  interest: e.internalLoanInterestCollected,
                ))
            .toList();

        return AsyncData((group, monthlyEntries));
      },
    ),
  );
});
