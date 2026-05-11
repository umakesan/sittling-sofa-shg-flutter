import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/savings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/shimmer_loader.dart';

// ─── Amount formatters (file-private) ────────────────────────────────────────

final _inrFmt =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

String _fmtFull(double v) => _inrFmt.format(v);

String _fmtCompact(double v) {
  final abs = v.abs();
  if (abs >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
  if (abs >= 100000) return '₹${(v / 100000).toStringAsFixed(2)} L';
  if (abs >= 1000) return '₹${(v / 1000).toStringAsFixed(1)} K';
  return '₹${v.toStringAsFixed(0)}';
}

/// Builds a map of entryMonth → running cumulative total (oldest → newest).
Map<String, double> _buildCumulativeMap(List<MonthlySavingsEntry> ledger) {
  final sorted = [...ledger]
    ..sort((a, b) => a.entryMonth.compareTo(b.entryMonth));
  double running = 0;
  final result = <String, double>{};
  for (final e in sorted) {
    running += e.total;
    result[e.entryMonth] = running;
  }
  return result;
}

String _fmtMonth(String entryMonth) {
  try {
    return DateFormat('MMM yyyy').format(DateTime.parse(entryMonth));
  } catch (_) {
    return entryMonth;
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

Widget _buildSkeleton() => ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(height: 100, margin: EdgeInsets.only(bottom: 12)),
        ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 12)),
        ShimmerCard(height: 56),
        ShimmerCard(height: 56),
        ShimmerCard(height: 56),
        ShimmerCard(height: 56),
      ],
    );

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL 1 — FEDERATION (All villages)
// ═══════════════════════════════════════════════════════════════════════════

class SavingsOverviewScreen extends ConsumerStatefulWidget {
  const SavingsOverviewScreen({super.key});

  @override
  ConsumerState<SavingsOverviewScreen> createState() =>
      _SavingsOverviewState();
}

class _SavingsOverviewState extends ConsumerState<SavingsOverviewScreen> {
  bool _sortByAmountDesc = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(villageSavingsSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savingsOverview),
        leading: context.canPop()
            ? BackButton(onPressed: () => context.pop())
            : null,
        actions: [
          _SortMenuButton(
            sortByAmountDesc: _sortByAmountDesc,
            onSortByAmount: () =>
                setState(() => _sortByAmountDesc = true),
            onSortByName: () =>
                setState(() => _sortByAmountDesc = false),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: null,
        onPressed: () => context.go('/'),
        backgroundColor: AppColors.primary,
        tooltip: AppLocalizations.of(context).home,
        child: const Icon(Icons.home_rounded, color: AppColors.textOnDark),
      ),
      body: dataAsync.when(
        loading: () => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
            child: _buildSkeleton(),
          ),
        ),
        error: (e, _) => Center(
          child: Text('$e',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
        data: (villages) {
          final sorted = [...villages];
          if (_sortByAmountDesc) {
            sorted.sort((a, b) => b.totalAsset.compareTo(a.totalAsset));
          } else {
            sorted.sort((a, b) => a.villageName.compareTo(b.villageName));
          }

          final totalAsset =
              villages.fold(0.0, (s, v) => s + v.totalAsset);
          final totalSavings =
              villages.fold(0.0, (s, v) => s + v.totalSavings);
          final totalInterest =
              villages.fold(0.0, (s, v) => s + v.totalInterest);
          final totalGroups =
              villages.fold(0, (s, v) => s + v.groupCount);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Hero card
                  _HeroCard(
                    label: l10n.totalSavingsAsset,
                    amount: totalAsset,
                    subtitle:
                        '${l10n.villagesCount(villages.length)}  ·  ${l10n.groupsCount(totalGroups)}',
                  ),
                  const SizedBox(height: 12),

                  // Two mini stat cards
                  _TwoStatRow(
                    leftLabel: l10n.savingsCorpus,
                    leftAmount: totalSavings,
                    leftIcon: Icons.savings_outlined,
                    leftColor: AppColors.primary,
                    rightLabel: l10n.interestEarned,
                    rightAmount: totalInterest,
                    rightIcon: Icons.trending_up_rounded,
                    rightColor: const Color(0xFF0369A1),
                  ),
                  const SizedBox(height: 20),

                  // Section header
                  _SectionLabel(
                    text: l10n.villagesCount(villages.length),
                  ),
                  const SizedBox(height: 8),

                  // Village list
                  ...sorted.map((v) => _VillageRow(
                        summary: v,
                        onTap: () => context.push(
                          '/reports/savings/village/${Uri.encodeComponent(v.villageName)}',
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL 2 — VILLAGE (All groups in one village)
// ═══════════════════════════════════════════════════════════════════════════

class VillageSavingsScreen extends ConsumerStatefulWidget {
  final String villageName;

  const VillageSavingsScreen({super.key, required this.villageName});

  @override
  ConsumerState<VillageSavingsScreen> createState() =>
      _VillageSavingsState();
}

class _VillageSavingsState extends ConsumerState<VillageSavingsScreen> {
  bool _sortByAmountDesc = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync =
        ref.watch(groupSavingsSummariesProvider(widget.villageName));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.villageName),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          _SortMenuButton(
            sortByAmountDesc: _sortByAmountDesc,
            onSortByAmount: () =>
                setState(() => _sortByAmountDesc = true),
            onSortByName: () =>
                setState(() => _sortByAmountDesc = false),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: null,
        onPressed: () => context.go('/'),
        backgroundColor: AppColors.primary,
        tooltip: AppLocalizations.of(context).home,
        child: const Icon(Icons.home_rounded, color: AppColors.textOnDark),
      ),
      body: dataAsync.when(
        loading: () => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
            child: _buildSkeleton(),
          ),
        ),
        error: (e, _) => Center(
          child: Text('$e',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
        data: (groups) {
          final sorted = [...groups];
          if (_sortByAmountDesc) {
            sorted.sort((a, b) => b.totalAsset.compareTo(a.totalAsset));
          } else {
            sorted
                .sort((a, b) => a.group.name.compareTo(b.group.name));
          }

          final totalAsset =
              groups.fold(0.0, (s, g) => s + g.totalAsset);
          final totalSavings =
              groups.fold(0.0, (s, g) => s + g.totalSavings);
          final totalInterest =
              groups.fold(0.0, (s, g) => s + g.totalInterest);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Village hero card
                  _HeroCard(
                    label: l10n.totalSavingsAsset,
                    amount: totalAsset,
                    subtitle: l10n.groupsCount(groups.length),
                  ),
                  const SizedBox(height: 12),

                  // Two mini stat cards
                  _TwoStatRow(
                    leftLabel: l10n.savingsCorpus,
                    leftAmount: totalSavings,
                    leftIcon: Icons.savings_outlined,
                    leftColor: AppColors.primary,
                    rightLabel: l10n.interestEarned,
                    rightAmount: totalInterest,
                    rightIcon: Icons.trending_up_rounded,
                    rightColor: const Color(0xFF0369A1),
                  ),
                  const SizedBox(height: 20),

                  // Section header
                  _SectionLabel(
                    text: l10n.groupsCount(groups.length),
                  ),
                  const SizedBox(height: 8),

                  if (groups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(l10n.noEntriesYet,
                            style: AppTextStyles.bodySecondary),
                      ),
                    )
                  else
                    ...sorted.map((g) => _GroupRow(
                          summary: g,
                          onTap: () => context.push(
                            '/reports/savings/group/${g.group.id}',
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL 3 — GROUP (Monthly savings ledger)
// ═══════════════════════════════════════════════════════════════════════════

class GroupSavingsScreen extends ConsumerWidget {
  final int groupId;

  const GroupSavingsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(groupSavingsLedgerProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: dataAsync.maybeWhen(
          data: (d) => Text(d.$1?.name ?? l10n.savings),
          orElse: () => Text(l10n.savings),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: null,
        onPressed: () => context.go('/'),
        backgroundColor: AppColors.primary,
        tooltip: AppLocalizations.of(context).home,
        child: const Icon(Icons.home_rounded, color: AppColors.textOnDark),
      ),
      body: dataAsync.when(
        loading: () => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
            child: _buildSkeleton(),
          ),
        ),
        error: (e, _) => Center(
          child: Text('$e',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
        data: (payload) {
          final group = payload.$1;
          final ledger = payload.$2;

          final totalSavings =
              ledger.fold(0.0, (s, e) => s + e.savings);
          final totalInterest =
              ledger.fold(0.0, (s, e) => s + e.interest);
          final totalAsset = totalSavings + totalInterest;
          final cumulativeMap = _buildCumulativeMap(ledger);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Group context chip
                  if (group != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${group.villageName}  ·  ${group.code}',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Hero card — total asset
                  _HeroCard(
                    label: l10n.totalSavingsAsset,
                    amount: totalAsset,
                    subtitle: l10n.groupsCount(ledger.length)
                        .replaceFirst('groups', 'months recorded')
                        .replaceFirst('group', 'month recorded'),
                  ),
                  const SizedBox(height: 12),

                  // Two mini stat cards
                  _TwoStatRow(
                    leftLabel: l10n.savingsCorpus,
                    leftAmount: totalSavings,
                    leftIcon: Icons.savings_outlined,
                    leftColor: AppColors.primary,
                    rightLabel: l10n.interestEarned,
                    rightAmount: totalInterest,
                    rightIcon: Icons.trending_up_rounded,
                    rightColor: const Color(0xFF0369A1),
                  ),
                  const SizedBox(height: 20),

                  // Ledger section header
                  _SectionLabel(text: l10n.monthlyLedger),
                  const SizedBox(height: 8),

                  if (ledger.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(l10n.noEntriesYet,
                            style: AppTextStyles.bodySecondary),
                      ),
                    )
                  else ...[
                    // Table header
                    _LedgerHeader(),
                    const Divider(height: 1, color: AppColors.border),
                    // Rows
                    ...ledger.map((e) => _LedgerRow(
                          entry: e,
                          cumulative: cumulativeMap[e.entryMonth] ?? 0,
                        )),
                    // Footer total
                    const Divider(height: 1, color: AppColors.borderStrong),
                    _LedgerTotalRow(
                      totalSavings: totalSavings,
                      totalInterest: totalInterest,
                      totalAsset: totalAsset,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Full-width green hero card with title, large amount, and subtitle.
class _HeroCard extends StatelessWidget {
  final String label;
  final double amount;
  final String subtitle;

  const _HeroCard({
    required this.label,
    required this.amount,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.sectionHeader
                  .copyWith(color: AppColors.textOnDarkMuted)),
          const SizedBox(height: 8),
          Text(
            _fmtCompact(amount),
            style: AppTextStyles.displayLarge
                .copyWith(color: AppColors.textOnDark, height: 1.1),
          ),
          const SizedBox(height: 6),
          Text(subtitle,
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textOnDarkMuted)),
        ],
      ),
    );
  }
}

/// Row of two equal-sized mini stat cards.
class _TwoStatRow extends StatelessWidget {
  final String leftLabel;
  final double leftAmount;
  final IconData leftIcon;
  final Color leftColor;
  final String rightLabel;
  final double rightAmount;
  final IconData rightIcon;
  final Color rightColor;

  const _TwoStatRow({
    required this.leftLabel,
    required this.leftAmount,
    required this.leftIcon,
    required this.leftColor,
    required this.rightLabel,
    required this.rightAmount,
    required this.rightIcon,
    required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MiniStatCard(
              label: leftLabel,
              amount: leftAmount,
              icon: leftIcon,
              accentColor: leftColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStatCard(
              label: rightLabel,
              amount: rightAmount,
              icon: rightIcon,
              accentColor: rightColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color accentColor;

  const _MiniStatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
          top: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
          bottom: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label.toUpperCase(),
                    style: AppTextStyles.sectionHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(_fmtFull(amount), style: AppTextStyles.amountSmall),
        ],
      ),
    );
  }
}

/// Grey uppercase label with a leading dot, used as a list section header.
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.sectionHeader,
    );
  }
}

/// Village list row — shown at federation level.
class _VillageRow extends StatelessWidget {
  final VillageSavingsSummary summary;
  final VoidCallback onTap;

  const _VillageRow({required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.location_city_rounded,
            size: 20, color: AppColors.primary),
      ),
      title: summary.villageName,
      subtitle: l10n.groupsCount(summary.groupCount),
      trailingAmount: summary.totalAsset,
      momChange: summary.momChange,
    );
  }
}

/// Group list row — shown at village level.
class _GroupRow extends StatelessWidget {
  final GroupSavingsSummary summary;
  final VoidCallback onTap;

  const _GroupRow({required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lastMonth = summary.lastEntryMonth != null
        ? l10n.lastEntryMonth(_fmtMonth(summary.lastEntryMonth!))
        : null;

    return _ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.group_outlined,
            size: 20, color: AppColors.primary),
      ),
      title: summary.group.name,
      subtitle: lastMonth ?? summary.group.code,
      trailingAmount: summary.totalAsset,
      momChange: summary.momChange,
    );
  }
}

/// Shared tappable list row used by both village and group rows.
class _ListTile extends StatelessWidget {
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final double trailingAmount;
  final double? momChange;

  const _ListTile({
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailingAmount,
    this.momChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_fmtFull(trailingAmount),
                      style: AppTextStyles.amountSmall),
                  const SizedBox(height: 2),
                  _TrendBadge(momChange: momChange),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small MoM trend indicator: ▲ +₹12K / ▼ -₹3K / — no data
class _TrendBadge extends StatelessWidget {
  final double? momChange;

  const _TrendBadge({this.momChange});

  @override
  Widget build(BuildContext context) {
    if (momChange == null || momChange == 0) {
      return Text('—',
          style: AppTextStyles.label.copyWith(color: AppColors.textTertiary));
    }
    final isUp = momChange! > 0;
    final color = isUp ? AppColors.synced : AppColors.error;
    final arrow = isUp ? '▲' : '▼';
    final sign = isUp ? '+' : '';
    return Text(
      '$arrow $sign${_fmtCompact(momChange!)}',
      style: AppTextStyles.label.copyWith(color: color),
    );
  }
}

// ─── Ledger table widgets ────────────────────────────────────────────────────

class _LedgerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(l10n.month,
                  style: AppTextStyles.sectionHeader)),
          Expanded(
              flex: 2,
              child: Text(l10n.savings,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.sectionHeader)),
          Expanded(
              flex: 2,
              child: Text(l10n.interest,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.sectionHeader)),
          Expanded(
              flex: 2,
              child: Text(l10n.metricTotal,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.sectionHeader)),
          Expanded(
              flex: 3,
              child: Text(l10n.cumulative,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.sectionHeader
                      .copyWith(color: AppColors.primary))),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final MonthlySavingsEntry entry;
  final double cumulative;

  const _LedgerRow({required this.entry, required this.cumulative});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(_fmtMonth(entry.entryMonth),
                  style: AppTextStyles.body)),
          Expanded(
              flex: 2,
              child: Text(_fmtCompact(entry.savings),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountSmall
                      .copyWith(color: AppColors.textSecondary))),
          Expanded(
              flex: 2,
              child: Text(_fmtCompact(entry.interest),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountSmall
                      .copyWith(color: const Color(0xFF0369A1)))),
          Expanded(
              flex: 2,
              child: Text(_fmtCompact(entry.total),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountSmall)),
          Expanded(
              flex: 3,
              child: Text(_fmtCompact(cumulative),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _LedgerTotalRow extends StatelessWidget {
  final double totalSavings;
  final double totalInterest;
  final double totalAsset;

  const _LedgerTotalRow({
    required this.totalSavings,
    required this.totalInterest,
    required this.totalAsset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(l10n.metricTotal.toUpperCase(),
                  style: AppTextStyles.label
                      .copyWith(fontWeight: FontWeight.w700))),
          Expanded(
              flex: 2,
              child: Text(_fmtCompact(totalSavings),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountSmall)),
          Expanded(
              flex: 2,
              child: Text(_fmtCompact(totalInterest),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountSmall)),
          Expanded(
              flex: 2,
              child: Text(_fmtCompact(totalAsset),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountSmall
                      .copyWith(color: AppColors.primary))),
          Expanded(
              flex: 3,
              child: Text(_fmtCompact(totalAsset),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

// ─── Sort menu ───────────────────────────────────────────────────────────────

class _SortMenuButton extends StatelessWidget {
  final bool sortByAmountDesc;
  final VoidCallback onSortByAmount;
  final VoidCallback onSortByName;

  const _SortMenuButton({
    required this.sortByAmountDesc,
    required this.onSortByAmount,
    required this.onSortByName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<bool>(
      tooltip: l10n.sortBy,
      icon: const Icon(Icons.sort_rounded),
      onSelected: (byAmount) =>
          byAmount ? onSortByAmount() : onSortByName(),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: true,
          child: Row(
            children: [
              Icon(Icons.arrow_downward_rounded,
                  size: 16,
                  color: sortByAmountDesc
                      ? AppColors.primary
                      : AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(l10n.sortHighestFirst),
              if (sortByAmountDesc) ...[
                const Spacer(),
                const Icon(Icons.check, size: 16, color: AppColors.primary),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: false,
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha_rounded,
                  size: 16,
                  color: !sortByAmountDesc
                      ? AppColors.primary
                      : AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(l10n.sortByName),
              if (!sortByAmountDesc) ...[
                const Spacer(),
                const Icon(Icons.check, size: 16, color: AppColors.primary),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
