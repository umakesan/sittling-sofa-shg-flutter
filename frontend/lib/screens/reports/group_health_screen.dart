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

String _fmtCompact(double v) {
  final abs = v.abs();
  if (abs >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
  if (abs >= 100000) return '₹${(v / 100000).toStringAsFixed(2)} L';
  if (abs >= 1000) return '₹${(v / 1000).toStringAsFixed(1)} K';
  return '₹${v.toStringAsFixed(0)}';
}

String _fmtPct(double pct) => '${pct.toStringAsFixed(0)}%';

String _fmtMonth(String ym) {
  try {
    return DateFormat('MMM yyyy').format(DateTime.parse(ym));
  } catch (_) {
    return ym;
  }
}

Color _healthColor(double pct) {
  if (pct >= 80) return AppColors.synced;
  if (pct >= 50) return AppColors.warning;
  return AppColors.error;
}

Widget _buildSkeleton() => ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(height: 100, margin: EdgeInsets.only(bottom: 12)),
        ShimmerCard(height: 64, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 64, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 64),
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
// LEVEL 1 — FEDERATION (village-level health overview)
// ═══════════════════════════════════════════════════════════════════════════════

class GroupHealthScreen extends ConsumerWidget {
  const GroupHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(villageHealthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupHealthReport),
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

          final totalGroups = villages.fold(0, (s, v) => s + v.totalGroups);
          final activeGroups = villages.fold(0, (s, v) => s + v.activeGroups);
          final avgRegularity = villages.isEmpty
              ? 0.0
              : villages.fold(0.0, (s, v) => s + v.avgRegularityPct) / villages.length;
          final totalCorpus = villages.fold(0.0, (s, v) => s + v.totalCorpus);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Hero
                  _HealthHero(
                    avgRegularity: avgRegularity,
                    totalGroups: totalGroups,
                    activeGroups: activeGroups,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),

                  // Corpus stat
                  _CorpusRow(corpus: totalCorpus, l10n: l10n),
                  const SizedBox(height: 20),

                  // Village list
                  Text(l10n.villagesCount(villages.length).toUpperCase(),
                      style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 8),

                  ...villages.map((v) => _VillageHealthTile(
                        summary: v,
                        l10n: l10n,
                        onTap: () => context.push('/reports/health/village/${Uri.encodeComponent(v.villageName)}'),
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

class _HealthHero extends StatelessWidget {
  final double avgRegularity;
  final int totalGroups;
  final int activeGroups;
  final AppLocalizations l10n;

  const _HealthHero({
    required this.avgRegularity,
    required this.totalGroups,
    required this.activeGroups,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = avgRegularity >= 80
        ? const LinearGradient(colors: [Color(0xFF14532D), Color(0xFF166534)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : avgRegularity >= 50
            ? const LinearGradient(colors: [Color(0xFF78350F), Color(0xFF92400E)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)], begin: Alignment.topLeft, end: Alignment.bottomRight);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.regularity.toUpperCase(),
              style: AppTextStyles.sectionHeader.copyWith(color: AppColors.textOnDarkMuted)),
          const SizedBox(height: 8),
          Text(_fmtPct(avgRegularity),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.textOnDark, height: 1.1)),
          const SizedBox(height: 6),
          Text(
            '${l10n.groupsCount(activeGroups)} active of ${l10n.groupsCount(totalGroups)}',
            style: AppTextStyles.label.copyWith(color: AppColors.textOnDarkMuted),
          ),
        ],
      ),
    );
  }
}

class _CorpusRow extends StatelessWidget {
  final double corpus;
  final AppLocalizations l10n;

  const _CorpusRow({required this.corpus, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
          top: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(children: [
        const Icon(Icons.savings_outlined, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(l10n.savingsCorpus.toUpperCase(), style: AppTextStyles.sectionHeader),
        const Spacer(),
        Text(_fmtCompact(corpus),
            style: AppTextStyles.amountSmall.copyWith(color: AppColors.primary)),
      ]),
    );
  }
}

class _VillageHealthTile extends StatelessWidget {
  final VillageHealthSummary summary;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _VillageHealthTile({required this.summary, required this.l10n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _healthColor(summary.avgRegularityPct);

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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_city_rounded, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(summary.villageName, style: AppTextStyles.title),
                  const SizedBox(height: 2),
                  Text(
                    '${summary.activeGroups}/${summary.totalGroups} active  ·  ${_fmtCompact(summary.totalCorpus)}',
                    style: AppTextStyles.label.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_fmtPct(summary.avgRegularityPct),
                    style: AppTextStyles.amountSmall.copyWith(color: color)),
                Text(l10n.regularity,
                    style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
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
// LEVEL 2 — VILLAGE (group-level scorecard)
// ═══════════════════════════════════════════════════════════════════════════════

class VillageHealthScreen extends ConsumerWidget {
  final String villageName;
  const VillageHealthScreen({super.key, required this.villageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(groupHealthScoresProvider(villageName));

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

          final avgReg = groups.isEmpty
              ? 0.0
              : groups.fold(0.0, (s, g) => s + g.regularityPct) / groups.length;
          final totalCorpus = groups.fold(0.0, (s, g) => s + g.savingsCorpus);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _HealthHero(
                    avgRegularity: avgReg,
                    totalGroups: groups.length,
                    activeGroups: groups.where((g) => g.lastEntryMonth != null).length,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _CorpusRow(corpus: totalCorpus, l10n: l10n),
                  const SizedBox(height: 20),
                  Text(l10n.groupsCount(groups.length).toUpperCase(), style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  _GroupScoreHeader(l10n: l10n),
                  const Divider(height: 1, color: AppColors.border),
                  ...groups.map((g) => _GroupScoreRow(score: g, l10n: l10n)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupScoreHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _GroupScoreHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(flex: 4, child: Text(l10n.groupsCount(0).replaceAll('0 groups', 'Group').replaceAll('0 group', 'Group'),
            style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.missingMonths, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 3, child: Text(l10n.regularity, textAlign: TextAlign.right,
            style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary))),
      ]),
    );
  }
}

class _GroupScoreRow extends StatelessWidget {
  final GroupHealthScore score;
  final AppLocalizations l10n;

  const _GroupScoreRow({required this.score, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final missing = (score.expectedMonths - score.actualMonths).clamp(0, score.expectedMonths);
    final color = _healthColor(score.regularityPct);

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(score.group.name, style: AppTextStyles.body),
              if (score.lastEntryMonth != null)
                Text('Last: ${_fmtMonth(score.lastEntryMonth!)}',
                    style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            missing > 0 ? '$missing' : '—',
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
                color: missing > 0 ? AppColors.pending : AppColors.textTertiary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmtPct(score.regularityPct),
                  style: AppTextStyles.amountSmall.copyWith(color: color)),
              LinearProgressIndicator(
                value: score.regularityPct / 100,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
