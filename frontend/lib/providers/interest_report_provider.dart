import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entries_provider.dart';
import 'groups_provider.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class GroupInterestRow {
  final int groupId;
  final String groupName;
  final double interest;
  const GroupInterestRow({
    required this.groupId,
    required this.groupName,
    required this.interest,
  });
}

class VillageInterestRow {
  final String villageName;
  final double totalInterest;
  final List<GroupInterestRow> groups;
  const VillageInterestRow({
    required this.villageName,
    required this.totalInterest,
    required this.groups,
  });
}

class InterestMonthData {
  final double totalInterest;
  final List<VillageInterestRow> villages; // sorted by village name
  const InterestMonthData({required this.totalInterest, required this.villages});
}

class InterestReportData {
  final List<String> months; // sorted oldest → newest "YYYY-MM-DD"
  final Map<String, InterestMonthData> byMonth;
  const InterestReportData({required this.months, required this.byMonth});
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final interestReportProvider = Provider<AsyncValue<InterestReportData>>((ref) {
  final groupsAsync = ref.watch(groupsProvider);
  final entriesAsync = ref.watch(entriesProvider);

  return groupsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
    data: (groups) => entriesAsync.when(
      loading: () => const AsyncValue.loading(),
      error: AsyncValue.error,
      data: (entries) {
        final groupById = {for (final g in groups) g.id: g};

        final allMonths = entries.map((e) => e.entryMonth).toSet().toList()
          ..sort();

        final byMonth = <String, InterestMonthData>{};
        for (final month in allMonths) {
          final monthEntries = entries.where((e) => e.entryMonth == month);

          final villageMap = <String, List<GroupInterestRow>>{};
          for (final entry in monthEntries) {
            final group = groupById[entry.groupId];
            if (group == null) continue;
            villageMap
                .putIfAbsent(group.villageName, () => [])
                .add(GroupInterestRow(
                  groupId: group.id,
                  groupName: group.name,
                  interest: entry.internalLoanInterestCollected,
                ));
          }

          final villages = villageMap.entries.map((e) {
            final gs = e.value..sort((a, b) => a.groupName.compareTo(b.groupName));
            return VillageInterestRow(
              villageName: e.key,
              totalInterest: gs.fold(0.0, (s, g) => s + g.interest),
              groups: gs,
            );
          }).toList()
            ..sort((a, b) => a.villageName.compareTo(b.villageName));

          byMonth[month] = InterestMonthData(
            totalInterest: villages.fold(0.0, (s, v) => s + v.totalInterest),
            villages: villages,
          );
        }

        return AsyncValue.data(
            InterestReportData(months: allMonths, byMonth: byMonth));
      },
    ),
  );
});
