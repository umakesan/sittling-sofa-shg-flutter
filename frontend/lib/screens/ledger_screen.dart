import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';

class LedgerScreen extends ConsumerWidget {
  final int groupId;

  const LedgerScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesProvider);
    final groupsAsync = ref.watch(groupsProvider);

    final group = groupsAsync.maybeWhen(
      data: (groups) =>
          groups.where((g) => g.id == groupId).firstOrNull,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? 'Group Ledger'),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (entries) {
          final groupEntries = entries
              .where((e) => e.groupId == groupId)
              .toList()
            ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));

          if (groupEntries.isEmpty) {
            return const Center(
              child: Text('No entries for this group yet.',
                  style: TextStyle(color: Colors.grey)),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStatePropertyAll(
                  const Color(0xFF2D6A4F).withOpacity(0.1)),
              columns: const [
                DataColumn(label: Text('Month')),
                DataColumn(label: Text('Savings'), numeric: true),
                DataColumn(label: Text('Int. Loan'), numeric: true),
                DataColumn(label: Text('SOFA Loan'), numeric: true),
                DataColumn(label: Text('Status')),
              ],
              rows: groupEntries.map((e) => _entryRow(context, e)).toList(),
            ),
          );
        },
      ),
    );
  }

  DataRow _entryRow(BuildContext context, MonthEntry e) {
    final month =
        DateFormat('MMM yyyy').format(DateTime.parse(e.entryMonth));
    final fmt = NumberFormat('#,##0', 'en_IN');

    return DataRow(
      onSelectChanged: (_) => context.push('/entries/edit', extra: e),
      cells: [
      DataCell(Text(month)),
      DataCell(Text('₹${fmt.format(e.savingsCollected)}')),
      DataCell(Text('₹${fmt.format(e.internalLoanPrincipalDisbursed)}')),
      DataCell(Text('₹${fmt.format(e.sofaLoanDisbursed)}')),
      DataCell(Row(children: [
        if (e.warningFlags.isNotEmpty)
          const Icon(Icons.warning_amber,
              size: 14, color: Color(0xFFF59E0B)),
        const SizedBox(width: 4),
        Text(
          e.syncStatus == SyncStatus.synced ? 'Synced' : 'Pending',
          style: TextStyle(
            fontSize: 12,
            color: e.syncStatus == SyncStatus.synced
                ? Colors.green.shade700
                : Colors.orange.shade700,
          ),
        ),
      ])),
    ]);
  }
}
