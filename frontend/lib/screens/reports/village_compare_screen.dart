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

// ─── Loading skeleton ──────────────────────────────────────────────────────────

Widget _buildSkeleton() => ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(height: 48, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 48, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 48, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 48, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 48),
      ],
    );

// ═══════════════════════════════════════════════════════════════════════════════
// VILLAGE COMPARE SCREEN (1-level — federation table)
// ═══════════════════════════════════════════════════════════════════════════════

class VillageCompareScreen extends ConsumerWidget {
  const VillageCompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(villageCompareProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.villageCompareReport),
        leading: context.canPop() ? BackButton(onPressed: () => context.pop()) : null,
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: null,
        onPressed: () => context.go('/'),
        backgroundColor: AppColors.primary,
        tooltip: l10n.home,
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
        error: (e, _) => Center(child: Text('$e', style: AppTextStyles.body.copyWith(color: AppColors.error))),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(child: Text(l10n.noEntriesYet, style: AppTextStyles.bodySecondary));
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 900 : 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary chips
                    Row(
                      children: [
                        _SummaryChip(
                          label: l10n.villagesCount(rows.length),
                          icon: Icons.location_city_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: l10n.totalSavingsAsset,
                          value: _fmtCompact(rows.fold(0.0, (s, r) => s + r.savingsAsset)),
                          icon: Icons.savings_outlined,
                          color: AppColors.synced,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Table header
                    _TableHeader(l10n: l10n),
                    const Divider(height: 1, color: AppColors.borderStrong),

                    // Rows
                    ...rows.asMap().entries.map((entry) {
                      final i = entry.key;
                      final r = entry.value;
                      return _TableRow(
                        row: r,
                        isEven: i.isEven,
                        l10n: l10n,
                      );
                    }),

                    // Footer totals
                    const Divider(height: 1, color: AppColors.borderStrong),
                    _TableFooter(rows: rows, l10n: l10n),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(value != null ? '$label: $value' : label,
              style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(flex: 4, child: Text(l10n.villageWideTotals.toUpperCase(), style: AppTextStyles.sectionHeader)),
        Expanded(flex: 3, child: Text(l10n.savingsOverview, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 3, child: Text(l10n.outstanding, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.recoveryRate, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
      ]),
    );
  }
}

class _TableRow extends StatelessWidget {
  final VillageCompareRow row;
  final bool isEven;
  final AppLocalizations l10n;

  const _TableRow({required this.row, required this.isEven, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? AppColors.surfaceCard : AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.villageName, style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text(
                '${l10n.groupsCount(row.groupCount)}  ·  ${l10n.groupsCount(row.activeGroupCount)} active',
                style: AppTextStyles.label.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(_fmtCompact(row.savingsAsset),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(color: AppColors.primary)),
        ),
        Expanded(
          flex: 3,
          child: Text(_fmtCompact(row.sofaOutstanding),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(
                  color: row.sofaOutstanding > 0 ? AppColors.pending : AppColors.textSecondary)),
        ),
        Expanded(
          flex: 2,
          child: Text(_fmtPct(row.sofaRecoveryPct),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(
                  color: row.sofaRecoveryPct >= 80 ? AppColors.synced : AppColors.warning)),
        ),
      ]),
    );
  }
}

class _TableFooter extends StatelessWidget {
  final List<VillageCompareRow> rows;
  final AppLocalizations l10n;

  const _TableFooter({required this.rows, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final totalSavings = rows.fold(0.0, (s, r) => s + r.savingsAsset);
    final totalOutstanding = rows.fold(0.0, (s, r) => s + r.sofaOutstanding);
    final totalGroups = rows.fold(0, (s, r) => s + r.groupCount);
    final activeGroups = rows.fold(0, (s, r) => s + r.activeGroupCount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.metricTotal.toUpperCase(),
                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${l10n.groupsCount(totalGroups)}  ·  ${l10n.groupsCount(activeGroups)} active',
                  style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(_fmtCompact(totalSavings),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          flex: 3,
          child: Text(_fmtCompact(totalOutstanding),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(fontWeight: FontWeight.w700)),
        ),
        const Expanded(flex: 2, child: SizedBox()),
      ]),
    );
  }
}
