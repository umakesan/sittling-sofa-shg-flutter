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

String _fmtMonth(String ym) {
  try {
    return DateFormat('MMM yy').format(DateTime.parse(ym));
  } catch (_) {
    return ym;
  }
}

Widget _buildSkeleton() => ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(height: 100, margin: EdgeInsets.only(bottom: 12)),
        ShimmerCard(height: 48, margin: EdgeInsets.only(bottom: 4)),
        ShimmerCard(height: 48, margin: EdgeInsets.only(bottom: 4)),
        ShimmerCard(height: 48, margin: EdgeInsets.only(bottom: 4)),
        ShimmerCard(height: 48),
      ],
    );

// ═══════════════════════════════════════════════════════════════════════════════
// TRENDS SCREEN (1-level — monthly federation-wide table, newest first)
// ═══════════════════════════════════════════════════════════════════════════════

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(trendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trendsReport),
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
        data: (months) {
          if (months.isEmpty) {
            return Center(child: Text(l10n.noEntriesYet, style: AppTextStyles.bodySecondary));
          }

          // Running cumulative corpus (oldest → newest)
          final sorted = [...months]..sort((a, b) => a.entryMonth.compareTo(b.entryMonth));
          double running = 0;
          final cumulativeMap = <String, double>{};
          for (final m in sorted) {
            running += m.totalAsset;
            cumulativeMap[m.entryMonth] = running;
          }

          final allTimeSavings = months.fold(0.0, (s, m) => s + m.savings);
          final allTimeInterest = months.fold(0.0, (s, m) => s + m.interest);
          final allTimeDisbursed = months.fold(0.0, (s, m) => s + m.sofaDisbursed);
          final allTimeRepaid = months.fold(0.0, (s, m) => s + m.sofaRepaid);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Hero corpus card
                  _CorpusCard(corpus: running, l10n: l10n),
                  const SizedBox(height: 12),

                  // All-time stat row
                  _AllTimeRow(
                    savingsTotal: allTimeSavings + allTimeInterest,
                    sofaOutstanding: allTimeDisbursed - allTimeRepaid,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 20),

                  // Monthly ledger
                  _TrendTableHeader(l10n: l10n),
                  const Divider(height: 1, color: AppColors.borderStrong),
                  ...months.map((m) => _TrendRow(
                        trend: m,
                        cumulative: cumulativeMap[m.entryMonth] ?? 0,
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

class _CorpusCard extends StatelessWidget {
  final double corpus;
  final AppLocalizations l10n;

  const _CorpusCard({required this.corpus, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A5C3A), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.corpusGrowth.toUpperCase(),
              style: AppTextStyles.sectionHeader.copyWith(color: AppColors.textOnDarkMuted)),
          const SizedBox(height: 8),
          Text(_fmtCompact(corpus),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.textOnDark, height: 1.1)),
          const SizedBox(height: 6),
          Text(l10n.savingsCorpus,
              style: AppTextStyles.label.copyWith(color: AppColors.textOnDarkMuted)),
        ],
      ),
    );
  }
}

class _AllTimeRow extends StatelessWidget {
  final double savingsTotal;
  final double sofaOutstanding;
  final AppLocalizations l10n;

  const _AllTimeRow({required this.savingsTotal, required this.sofaOutstanding, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.savingsCorpus,
              value: _fmtCompact(savingsTotal),
              icon: Icons.savings_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              label: l10n.outstanding,
              value: _fmtCompact(sofaOutstanding),
              icon: Icons.account_balance_outlined,
              color: AppColors.pending,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

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
          Text(value, style: AppTextStyles.amountSmall),
        ],
      ),
    );
  }
}

class _TrendTableHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _TrendTableHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(flex: 2, child: Text(l10n.month, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.monthlyContributions, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 2, child: Text(l10n.sofaLoansReport, textAlign: TextAlign.right, style: AppTextStyles.sectionHeader)),
        Expanded(flex: 3, child: Text(l10n.corpusGrowth, textAlign: TextAlign.right,
            style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary))),
      ]),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final MonthlyFederationTrend trend;
  final double cumulative;

  const _TrendRow({required this.trend, required this.cumulative});

  @override
  Widget build(BuildContext context) {
    final sofaNet = trend.sofaRepaid - trend.sofaDisbursed;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_fmtMonth(trend.entryMonth), style: AppTextStyles.body),
              Text('${trend.entryCount} entries', style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(_fmtCompact(trend.totalAsset),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          flex: 2,
          child: Text(
            (sofaNet >= 0 ? '+' : '') + _fmtCompact(sofaNet),
            textAlign: TextAlign.right,
            style: AppTextStyles.amountSmall.copyWith(
                color: sofaNet >= 0 ? AppColors.synced : AppColors.pending),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(_fmtCompact(cumulative),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
