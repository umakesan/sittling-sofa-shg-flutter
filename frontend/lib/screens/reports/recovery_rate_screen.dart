import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/reports_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/shimmer_loader.dart';

// ─── Formatters ────────────────────────────────────────────────────────────────

String _fmtCompact(double v) {
  final abs = v.abs();
  if (abs >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
  if (abs >= 100000) return '₹${(v / 100000).toStringAsFixed(2)} L';
  if (abs >= 1000) return '₹${(v / 1000).toStringAsFixed(1)} K';
  return '₹${v.toStringAsFixed(0)}';
}

String _fmtPct(double pct) => '${pct.toStringAsFixed(1)}%';

Color _recoveryColor(double pct) {
  if (pct >= 80) return AppColors.synced;
  if (pct >= 50) return AppColors.warning;
  return AppColors.error;
}

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

Widget _homeFab(BuildContext context) => FloatingActionButton.small(
      heroTag: null,
      onPressed: () => context.go('/'),
      backgroundColor: AppColors.primary,
      tooltip: AppLocalizations.of(context).home,
      child: const Icon(Icons.home_rounded, color: AppColors.textOnDark),
    );

// ═══════════════════════════════════════════════════════════════════════════════
// LEVEL 1 — FEDERATION
// ═══════════════════════════════════════════════════════════════════════════════

class RecoveryRateScreen extends ConsumerWidget {
  const RecoveryRateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(villageRecoveryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recoveryRateReport),
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
          if (villages.isEmpty) {
            return Center(child: Text(l10n.noEntriesYet, style: AppTextStyles.bodySecondary));
          }

          final totalDisbursed = villages.fold(0.0, (s, v) => s + v.totalDisbursed);
          final totalRepaid = villages.fold(0.0, (s, v) => s + v.totalRepaid);
          final overallPct = totalDisbursed > 0 ? totalRepaid / totalDisbursed * 100 : 0.0;
          final outstanding = totalDisbursed - totalRepaid;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _RecoveryHero(
                    recoveryPct: overallPct,
                    outstanding: outstanding,
                    l10n: l10n,
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
                  Text(l10n.villagesCount(villages.length).toUpperCase(), style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  _TableHeader(l10n: l10n),
                  const Divider(height: 1, color: AppColors.borderStrong),
                  ...villages.map((v) => _VillageRecoveryRow(
                        summary: v,
                        l10n: l10n,
                        onTap: () => context.push('/reports/recovery/village/${Uri.encodeComponent(v.villageName)}'),
                      )),
                  const Divider(height: 1, color: AppColors.borderStrong),
                  _FooterRow(
                    totalDisbursed: totalDisbursed,
                    totalRepaid: totalRepaid,
                    outstanding: outstanding,
                    overallPct: overallPct,
                    l10n: l10n,
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

class _RecoveryHero extends StatelessWidget {
  final double recoveryPct;
  final double outstanding;
  final AppLocalizations l10n;

  const _RecoveryHero({required this.recoveryPct, required this.outstanding, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final gradient = recoveryPct >= 80
        ? const LinearGradient(colors: [Color(0xFF14532D), Color(0xFF166534)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : recoveryPct >= 50
            ? const LinearGradient(colors: [Color(0xFF78350F), Color(0xFF92400E)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)], begin: Alignment.topLeft, end: Alignment.bottomRight);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.recoveryRate.toUpperCase(),
              style: AppTextStyles.sectionHeader.copyWith(color: AppColors.textOnDarkMuted)),
          const SizedBox(height: 8),
          Text(_fmtPct(recoveryPct),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.textOnDark, height: 1.1)),
          const SizedBox(height: 6),
          Text('${l10n.outstanding}: ${_fmtCompact(outstanding)}',
              style: AppTextStyles.label.copyWith(color: AppColors.textOnDarkMuted)),
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
          Expanded(child: _StatCard(label: leftLabel, amount: leftAmount, icon: leftIcon, color: leftColor)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(label: rightLabel, amount: rightAmount, icon: rightIcon, color: rightColor)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 3),
          top: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
          bottom: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label.toUpperCase(),
                  style: AppTextStyles.sectionHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 6),
          Text(_fmtCompact(amount), style: AppTextStyles.amountSmall),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _TableHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(flex: 3, child: Text('Village', style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.outstanding, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.recoveryRate, textAlign: TextAlign.right,
            style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary))),
      ]),
    );
  }
}

class _VillageRecoveryRow extends StatelessWidget {
  final VillageRecoverySummary summary;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _VillageRecoveryRow({required this.summary, required this.l10n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _recoveryColor(summary.recoveryPct);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.villageName, style: AppTextStyles.title),
                Text(l10n.groupsCount(summary.groupCount),
                    style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(_fmtCompact(summary.outstanding),
                textAlign: TextAlign.right,
                style: AppTextStyles.amountSmall.copyWith(
                    color: summary.outstanding > 0 ? AppColors.pending : AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_fmtPct(summary.recoveryPct),
                    style: AppTextStyles.amountSmall.copyWith(color: color)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  final double totalDisbursed;
  final double totalRepaid;
  final double outstanding;
  final double overallPct;
  final AppLocalizations l10n;

  const _FooterRow({
    required this.totalDisbursed,
    required this.totalRepaid,
    required this.outstanding,
    required this.overallPct,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Text(l10n.metricTotal.toUpperCase(),
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        ),
        Expanded(
          flex: 2,
          child: Text(_fmtCompact(outstanding),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(fontWeight: FontWeight.w700)),
        ),
        Expanded(
          flex: 2,
          child: Text(_fmtPct(overallPct),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(
                  color: _recoveryColor(overallPct), fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEVEL 2 — VILLAGE (group-level recovery)
// ═══════════════════════════════════════════════════════════════════════════════

class VillageRecoveryScreen extends ConsumerWidget {
  final String villageName;
  const VillageRecoveryScreen({super.key, required this.villageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(groupRecoveryProvider(villageName));

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
          if (groups.isEmpty) {
            return Center(child: Text(l10n.noEntriesYet, style: AppTextStyles.bodySecondary));
          }

          final totalDisbursed = groups.fold(0.0, (s, g) => s + g.disbursed);
          final totalRepaid = groups.fold(0.0, (s, g) => s + g.repaid);
          final overallPct = totalDisbursed > 0 ? totalRepaid / totalDisbursed * 100 : 0.0;
          final outstanding = totalDisbursed - totalRepaid;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _RecoveryHero(recoveryPct: overallPct, outstanding: outstanding, l10n: l10n),
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
                  Text(l10n.groupsCount(groups.length).toUpperCase(), style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  _TableHeader(l10n: l10n),
                  const Divider(height: 1, color: AppColors.borderStrong),
                  ...groups.map((g) => _GroupRecoveryRow(summary: g, l10n: l10n)),
                  const Divider(height: 1, color: AppColors.borderStrong),
                  _FooterRow(
                    totalDisbursed: totalDisbursed,
                    totalRepaid: totalRepaid,
                    outstanding: outstanding,
                    overallPct: overallPct,
                    l10n: l10n,
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

class _GroupRecoveryRow extends StatelessWidget {
  final GroupRecoverySummary summary;
  final AppLocalizations l10n;

  const _GroupRecoveryRow({required this.summary, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = _recoveryColor(summary.recoveryPct);
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary.group.name, style: AppTextStyles.body),
              Text(summary.group.code,
                  style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(_fmtCompact(summary.outstanding),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(
                  color: summary.outstanding > 0 ? AppColors.pending : AppColors.textSecondary)),
        ),
        Expanded(
          flex: 2,
          child: Text(_fmtPct(summary.recoveryPct),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(color: color)),
        ),
      ]),
    );
  }
}
