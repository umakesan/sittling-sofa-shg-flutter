import 'package:flutter/material.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/group.dart';
import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

final _dayRegex = RegExp(r'[-\s]+(\d{1,2})\s*$');

int? _extractDay(String name) {
  final m = _dayRegex.firstMatch(name);
  if (m == null) return null;
  return int.tryParse(m.group(1)!);
}

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

          double totalSavings = 0;
          for (final e in groupEntries) {
            totalSavings += e.savingsCollected;
          }
          final lastEntry = groupEntries.isEmpty ? null : groupEntries.first;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _LedgerHero(
                      group: group,
                      totalSavings: totalSavings,
                      monthsRecorded: groupEntries.length,
                      lastEntry: lastEntry,
                      l10n: l10n,
                    ),
                  ),
                  if (groupEntries.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(l10n.noGroupEntriesYet,
                            style: AppTextStyles.bodySecondary),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _LedgerRow(
                            entry: groupEntries[i],
                            l10n: l10n,
                          ),
                          childCount: groupEntries.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _LedgerHero extends StatelessWidget {
  final Group? group;
  final double totalSavings;
  final int monthsRecorded;
  final MonthEntry? lastEntry;
  final AppLocalizations l10n;

  const _LedgerHero({
    required this.group,
    required this.totalSavings,
    required this.monthsRecorded,
    required this.lastEntry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final day = group != null ? _extractDay(group!.name) : null;
    final lastMonthText = lastEntry != null
        ? DateFormat('MMM yyyy').format(DateTime.parse(lastEntry!.entryMonth))
        : '—';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A5C3A), Color(0xFF0C3320)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A5C3A).withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -24,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name
                  Text(
                    group?.name ?? l10n.groupLedger,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Village + meeting day
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: Color(0x99FFFFFF)),
                      const SizedBox(width: 4),
                      Text(
                        group?.villageName ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xAAFFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (day != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0x55FFFFFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Meets on the ${day}th',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xAAFFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            label: l10n.totalSavingsCollected,
                            value: fmt.format(totalSavings),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.white.withOpacity(0.15),
                          width: 24,
                          thickness: 1,
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'Months recorded',
                            value: '$monthsRecorded',
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.white.withOpacity(0.15),
                          width: 24,
                          thickness: 1,
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'Last entry',
                            value: lastMonthText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0x77FFFFFF),
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xEEFFFFFF),
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Ledger row ────────────────────────────────────────────────────────────────

class _LedgerRow extends StatelessWidget {
  final MonthEntry entry;
  final AppLocalizations l10n;

  const _LedgerRow({required this.entry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(entry.entryMonth);
    final monthLabel = DateFormat('MMM').format(date).toUpperCase();
    final yearLabel = DateFormat('yyyy').format(date);
    final fmt = NumberFormat('#,##0', 'en_IN');
    const Color badgeBg = AppColors.syncedBg;
    const Color badgeText = AppColors.synced;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/entries/edit', extra: entry),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Month badge
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: badgeText.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: badgeText,
                        letterSpacing: 0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      yearLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeText.withOpacity(0.7),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Amounts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AmountRow(
                      label: l10n.savings,
                      value: '₹${fmt.format(entry.savingsCollected)}',
                    ),
                    const SizedBox(height: 3),
                    _AmountRow(
                      label: l10n.intLoan,
                      value: '₹${fmt.format(entry.internalLoanPrincipalDisbursed)}',
                    ),
                    const SizedBox(height: 3),
                    _AmountRow(
                      label: l10n.sofaLoan,
                      value: '₹${fmt.format(entry.sofaLoanDisbursed)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
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
