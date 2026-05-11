import 'package:flutter/material.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/status_pill.dart';

class LedgerScreen extends ConsumerWidget {
  final int groupId;

  const LedgerScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entriesAsync = ref.watch(entriesProvider);
    final groupsAsync = ref.watch(groupsProvider);

    final group = groupsAsync.maybeWhen(
      data: (groups) => groups.where((g) => g.id == groupId).firstOrNull,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? l10n.groupLedger),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
        data: (entries) {
          final groupEntries = entries
              .where((e) => e.groupId == groupId)
              .toList()
            ..sort((a, b) => b.entryMonth.compareTo(a.entryMonth));

          if (groupEntries.isEmpty) {
            return Center(
              child: Text(l10n.noGroupEntriesYet,
                  style: AppTextStyles.bodySecondary),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: groupEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _LedgerRow(entry: groupEntries[i], l10n: l10n),
          );
        },
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final MonthEntry entry;
  final AppLocalizations l10n;

  const _LedgerRow({required this.entry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMM yyyy').format(DateTime.parse(entry.entryMonth));
    final fmt = NumberFormat('#,##0', 'en_IN');
    final isPending = entry.syncStatus == SyncStatus.pendingSync;
    final hasWarning = entry.warningFlags.isNotEmpty;

    return InkWell(
      onTap: () => context.push('/entries/edit', extra: entry),
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.primaryContainer,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(month,
                  style: AppTextStyles.title.copyWith(fontSize: 14)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AmountRow(
                    label: l10n.savings,
                    value: '₹${fmt.format(entry.savingsCollected)}',
                  ),
                  const SizedBox(height: 2),
                  _AmountRow(
                    label: l10n.intLoan,
                    value: '₹${fmt.format(entry.internalLoanPrincipalDisbursed)}',
                  ),
                  const SizedBox(height: 2),
                  _AmountRow(
                    label: l10n.sofaLoan,
                    value: '₹${fmt.format(entry.sofaLoanDisbursed)}',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusPill(
              status: isPending
                  ? EntryStatus.pending
                  : hasWarning
                      ? EntryStatus.savedWithWarnings
                      : EntryStatus.synced,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;

  const _AmountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value, style: AppTextStyles.amountSmall),
      ],
    );
  }
}
