import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/reports_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/shimmer_loader.dart';

// ─── Formatters ────────────────────────────────────────────────────────────────

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

String _fmtMonth(String ym) {
  try {
    return DateFormat('MMM yyyy').format(DateTime.parse(ym));
  } catch (_) {
    return ym;
  }
}

String _fmtPct(double pct) => '${pct.toStringAsFixed(1)}%';

Widget _buildSkeleton() => ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(height: 100, margin: EdgeInsets.only(bottom: 12)),
        ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 12)),
        ShimmerCard(height: 56),
        ShimmerCard(height: 56),
        ShimmerCard(height: 56),
      ],
    );

// ─── Home FAB ──────────────────────────────────────────────────────────────────

Widget _homeFab(BuildContext context) => FloatingActionButton.small(
      heroTag: null,
      onPressed: () => context.go('/'),
      backgroundColor: AppColors.primary,
      tooltip: AppLocalizations.of(context).home,
      child: const Icon(Icons.home_rounded, color: AppColors.textOnDark),
    );

// ─── Shared hero card ──────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String label;
  final double amount;
  final String subtitle;

  const _HeroCard(
      {required this.label, required this.amount, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C4A6E), Color(0xFF0369A1)],
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
          Text(_fmtCompact(amount),
              style: AppTextStyles.displayLarge
                  .copyWith(color: AppColors.textOnDark, height: 1.1)),
          const SizedBox(height: 6),
          Text(subtitle,
              style:
                  AppTextStyles.label.copyWith(color: AppColors.textOnDarkMuted)),
        ],
      ),
    );
  }
}

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
          Expanded(child: _MiniStatCard(label: leftLabel, amount: leftAmount, icon: leftIcon, accentColor: leftColor)),
          const SizedBox(width: 10),
          Expanded(child: _MiniStatCard(label: rightLabel, amount: rightAmount, icon: rightIcon, accentColor: rightColor)),
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

  const _MiniStatCard({required this.label, required this.amount, required this.icon, required this.accentColor});

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
          Row(children: [
            Icon(icon, size: 14, color: accentColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label.toUpperCase(),
                  style: AppTextStyles.sectionHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 6),
          Text(_fmtFull(amount), style: AppTextStyles.amountSmall),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppTextStyles.sectionHeader);
}

class _ListTile extends StatelessWidget {
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final String trailingTop;
  final String trailingBottom;

  const _ListTile({
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailingTop,
    required this.trailingBottom,
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
          child: Row(children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(trailingTop, style: AppTextStyles.amountSmall),
                const SizedBox(height: 2),
                Text(trailingBottom, style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEVEL 1 — FEDERATION
// ═══════════════════════════════════════════════════════════════════════════════

class SofaLoansScreen extends ConsumerWidget {
  const SofaLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(villageSofaSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sofaLoansReport),
        leading: context.canPop() ? BackButton(onPressed: () => context.pop()) : null,
      ),
      floatingActionButton: _homeFab(context),
      body: dataAsync.when(
        loading: () => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
            child: _buildSkeleton(),
          ),
        ),
        error: (e, _) => Center(child: Text('$e', style: AppTextStyles.body.copyWith(color: AppColors.error))),
        data: (villages) {
          final totalDisbursed = villages.fold(0.0, (s, v) => s + v.totalDisbursed);
          final totalRepaid = villages.fold(0.0, (s, v) => s + v.totalRepaid);
          final totalInterest = villages.fold(0.0, (s, v) => s + v.totalInterest);
          final outstanding = totalDisbursed - totalRepaid;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _HeroCard(
                    label: l10n.outstanding,
                    amount: outstanding,
                    subtitle: l10n.villagesCount(villages.length),
                  ),
                  const SizedBox(height: 12),
                  _TwoStatRow(
                    leftLabel: l10n.loanDisbursed,
                    leftAmount: totalDisbursed,
                    leftIcon: Icons.arrow_upward_rounded,
                    leftColor: AppColors.pending,
                    rightLabel: l10n.loanReturn,
                    rightAmount: totalRepaid,
                    rightIcon: Icons.arrow_downward_rounded,
                    rightColor: AppColors.synced,
                  ),
                  const SizedBox(height: 12),
                  _TwoStatRow(
                    leftLabel: l10n.interest,
                    leftAmount: totalInterest,
                    leftIcon: Icons.percent_rounded,
                    leftColor: const Color(0xFF7C3AED),
                    rightLabel: l10n.recoveryRate,
                    rightAmount: totalDisbursed > 0 ? totalRepaid / totalDisbursed * 100 : 0,
                    rightIcon: Icons.trending_up_rounded,
                    rightColor: const Color(0xFF0369A1),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(text: l10n.villagesCount(villages.length)),
                  const SizedBox(height: 8),
                  ...villages.map((v) => _ListTile(
                        onTap: () => context.push('/reports/sofa/village/${Uri.encodeComponent(v.villageName)}'),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_city_rounded, size: 20, color: Color(0xFF0369A1)),
                        ),
                        title: v.villageName,
                        subtitle: l10n.groupsCount(v.groupCount),
                        trailingTop: _fmtCompact(v.totalDisbursed - v.totalRepaid),
                        trailingBottom: _fmtPct(v.recoveryPct),
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

// ═══════════════════════════════════════════════════════════════════════════════
// LEVEL 2 — VILLAGE
// ═══════════════════════════════════════════════════════════════════════════════

class VillageSofaScreen extends ConsumerWidget {
  final String villageName;
  const VillageSofaScreen({super.key, required this.villageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(groupSofaSummariesProvider(villageName));

    return Scaffold(
      appBar: AppBar(
        title: Text(villageName),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      floatingActionButton: _homeFab(context),
      body: dataAsync.when(
        loading: () => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640), child: _buildSkeleton()),
        ),
        error: (e, _) => Center(child: Text('$e', style: AppTextStyles.body.copyWith(color: AppColors.error))),
        data: (groups) {
          final totalDisbursed = groups.fold(0.0, (s, g) => s + g.totalDisbursed);
          final totalRepaid = groups.fold(0.0, (s, g) => s + g.totalRepaid);
          final totalInterest = groups.fold(0.0, (s, g) => s + g.totalInterest);
          final outstanding = totalDisbursed - totalRepaid;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _HeroCard(
                    label: l10n.outstanding,
                    amount: outstanding,
                    subtitle: l10n.groupsCount(groups.length),
                  ),
                  const SizedBox(height: 12),
                  _TwoStatRow(
                    leftLabel: l10n.loanDisbursed,
                    leftAmount: totalDisbursed,
                    leftIcon: Icons.arrow_upward_rounded,
                    leftColor: AppColors.pending,
                    rightLabel: l10n.loanReturn,
                    rightAmount: totalRepaid,
                    rightIcon: Icons.arrow_downward_rounded,
                    rightColor: AppColors.synced,
                  ),
                  const SizedBox(height: 12),
                  _TwoStatRow(
                    leftLabel: l10n.interest,
                    leftAmount: totalInterest,
                    leftIcon: Icons.percent_rounded,
                    leftColor: const Color(0xFF7C3AED),
                    rightLabel: l10n.recoveryRate,
                    rightAmount: totalDisbursed > 0 ? totalRepaid / totalDisbursed * 100 : 0,
                    rightIcon: Icons.trending_up_rounded,
                    rightColor: const Color(0xFF0369A1),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(text: l10n.groupsCount(groups.length)),
                  const SizedBox(height: 8),
                  if (groups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(child: Text(l10n.noEntriesYet, style: AppTextStyles.bodySecondary)),
                    )
                  else
                    ...groups.map((g) => _ListTile(
                          onTap: () => context.push('/reports/sofa/group/${g.group.id}'),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.group_outlined, size: 20, color: AppColors.primary),
                          ),
                          title: g.group.name,
                          subtitle: g.lastEntryMonth != null ? _fmtMonth(g.lastEntryMonth!) : g.group.code,
                          trailingTop: _fmtCompact(g.outstanding),
                          trailingBottom: _fmtPct(g.recoveryPct),
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

// ═══════════════════════════════════════════════════════════════════════════════
// LEVEL 3 — GROUP LEDGER
// ═══════════════════════════════════════════════════════════════════════════════

class GroupSofaScreen extends ConsumerWidget {
  final int groupId;
  const GroupSofaScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(groupSofaLedgerProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: dataAsync.maybeWhen(
          data: (d) => Text(d.$1?.name ?? l10n.sofaLoansReport),
          orElse: () => Text(l10n.sofaLoansReport),
        ),
      ),
      floatingActionButton: _homeFab(context),
      body: dataAsync.when(
        loading: () => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640), child: _buildSkeleton()),
        ),
        error: (e, _) => Center(child: Text('$e', style: AppTextStyles.body.copyWith(color: AppColors.error))),
        data: (payload) {
          final group = payload.$1;
          final ledger = payload.$2;
          final totalDisbursed = ledger.fold(0.0, (s, e) => s + e.disbursed);
          final totalRepaid = ledger.fold(0.0, (s, e) => s + e.repaid);
          final totalInterest = ledger.fold(0.0, (s, e) => s + e.interest);
          final outstanding = totalDisbursed - totalRepaid;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  if (group != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('${group.villageName}  ·  ${group.code}',
                              style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _HeroCard(
                    label: l10n.outstanding,
                    amount: outstanding,
                    subtitle: '${ledger.length} months recorded',
                  ),
                  const SizedBox(height: 12),
                  _TwoStatRow(
                    leftLabel: l10n.loanDisbursed,
                    leftAmount: totalDisbursed,
                    leftIcon: Icons.arrow_upward_rounded,
                    leftColor: AppColors.pending,
                    rightLabel: l10n.loanReturn,
                    rightAmount: totalRepaid,
                    rightIcon: Icons.arrow_downward_rounded,
                    rightColor: AppColors.synced,
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(text: l10n.monthlyLedger),
                  const SizedBox(height: 8),
                  if (ledger.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(child: Text(l10n.noEntriesYet, style: AppTextStyles.bodySecondary)),
                    )
                  else ...[
                    _SofaLedgerHeader(l10n: l10n),
                    const Divider(height: 1, color: AppColors.border),
                    ...ledger.map((e) => _SofaLedgerRow(entry: e)),
                    const Divider(height: 1, color: AppColors.borderStrong),
                    _SofaLedgerTotalRow(
                      totalDisbursed: totalDisbursed,
                      totalRepaid: totalRepaid,
                      totalInterest: totalInterest,
                      outstanding: outstanding,
                      l10n: l10n,
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

class _SofaLedgerHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _SofaLedgerHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(flex: 3, child: Text(l10n.month, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.loanDisbursed, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.loanReturn, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.outstanding, textAlign: TextAlign.right,
            style: AppTextStyles.sectionHeader.copyWith(color: AppColors.pending))),
      ]),
    );
  }
}

class _SofaLedgerRow extends StatelessWidget {
  final MonthlySofaEntry entry;
  const _SofaLedgerRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final outstanding = entry.disbursed - entry.repaid;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(flex: 3, child: Text(_fmtMonth(entry.entryMonth), style: AppTextStyles.body)),
        Expanded(flex: 2, child: Text(_fmtCompact(entry.disbursed),
            textAlign: TextAlign.right,
            style: AppTextStyles.amountSmall.copyWith(color: AppColors.textSecondary))),
        Expanded(flex: 2, child: Text(_fmtCompact(entry.repaid),
            textAlign: TextAlign.right,
            style: AppTextStyles.amountSmall.copyWith(color: AppColors.synced))),
        Expanded(flex: 2, child: Text(_fmtCompact(outstanding),
            textAlign: TextAlign.right,
            style: AppTextStyles.amountSmall.copyWith(
                color: outstanding > 0 ? AppColors.pending : AppColors.synced))),
      ]),
    );
  }
}

class _SofaLedgerTotalRow extends StatelessWidget {
  final double totalDisbursed;
  final double totalRepaid;
  final double totalInterest;
  final double outstanding;
  final AppLocalizations l10n;

  const _SofaLedgerTotalRow({
    required this.totalDisbursed,
    required this.totalRepaid,
    required this.totalInterest,
    required this.outstanding,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(flex: 3, child: Text(l10n.metricTotal.toUpperCase(),
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700))),
        Expanded(flex: 2, child: Text(_fmtCompact(totalDisbursed),
            textAlign: TextAlign.right, style: AppTextStyles.amountSmall)),
        Expanded(flex: 2, child: Text(_fmtCompact(totalRepaid),
            textAlign: TextAlign.right, style: AppTextStyles.amountSmall)),
        Expanded(flex: 2, child: Text(_fmtCompact(outstanding),
            textAlign: TextAlign.right,
            style: AppTextStyles.amountSmall.copyWith(
                color: AppColors.pending, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
