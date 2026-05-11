import 'package:flutter/material.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/shimmer_loader.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entriesAsync = ref.watch(entriesProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        leading: context.canPop()
            ? BackButton(onPressed: () => context.pop())
            : null,
      ),
      body: entriesAsync.when(
        loading: () => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ShimmerCard(height: 28, margin: EdgeInsets.only(bottom: 20)),
                ShimmerCard(height: 56),
                ShimmerCard(height: 56),
                ShimmerCard(height: 56),
                ShimmerCard(height: 56),
                ShimmerCard(height: 56),
              ],
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Text('$e',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
        data: (entries) {
          final summary = _summarise(entries);

          final cards = [
            _StatCard(
              icon: Icons.savings_outlined,
              iconColor: AppColors.synced,
              label: l10n.totalSavingsCollected,
              value: summary.totalSavingsCollected,
            ),
            _StatCard(
              icon: Icons.people_outline,
              iconColor: AppColors.primary,
              label: l10n.internalLoanPrincipal,
              value: summary.totalInternalLoanPrincipal,
            ),
            _StatCard(
              icon: Icons.percent_rounded,
              iconColor: AppColors.primaryLight,
              label: l10n.internalLoanInterest,
              value: summary.totalInternalLoanInterest,
            ),
            _StatCard(
              icon: Icons.arrow_upward_rounded,
              iconColor: AppColors.warning,
              label: l10n.sofaLoansDisbursed,
              value: summary.totalSofaDisbursed,
            ),
            _StatCard(
              icon: Icons.arrow_downward_rounded,
              iconColor: AppColors.synced,
              label: l10n.sofaLoansRepaid,
              value: summary.totalSofaRepaid,
            ),
          ];

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l10n.villageWideTotals, style: AppTextStyles.headline),
                  const SizedBox(height: 4),
                  Text(
                    l10n.basedOnEntries(entries.length),
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 20),

                  // 2-col grid on tablet, single col on mobile
                  if (isTablet)
                    ..._buildGrid(cards)
                  else
                    ...cards,

                  if (summary.warningEntryCount > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warningBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.warningIcon, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.warningEntriesCount(
                                  summary.warningEntryCount),
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
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

  List<Widget> _buildGrid(List<Widget> cards) {
    final rows = <Widget>[];
    for (int i = 0; i < cards.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[i]),
              const SizedBox(width: 10),
              if (i + 1 < cards.length)
                Expanded(child: cards[i + 1])
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    return rows;
  }

  _DashboardSummary _summarise(List<MonthEntry> entries) {
    double savings = 0, principal = 0, interest = 0, sofa = 0, sofaRepaid = 0;
    int warnings = 0;
    for (final e in entries) {
      savings += e.savingsCollected;
      principal += e.internalLoanPrincipalDisbursed;
      interest += e.internalLoanInterestCollected;
      sofa += e.sofaLoanDisbursed;
      sofaRepaid += e.sofaLoanRepayment;
      if (e.warningFlags.isNotEmpty) warnings++;
    }
    return _DashboardSummary(
      totalSavingsCollected: savings,
      totalInternalLoanPrincipal: principal,
      totalInternalLoanInterest: interest,
      totalSofaDisbursed: sofa,
      totalSofaRepaid: sofaRepaid,
      warningEntryCount: warnings,
    );
  }
}

class _DashboardSummary {
  final double totalSavingsCollected;
  final double totalInternalLoanPrincipal;
  final double totalInternalLoanInterest;
  final double totalSofaDisbursed;
  final double totalSofaRepaid;
  final int warningEntryCount;

  const _DashboardSummary({
    required this.totalSavingsCollected,
    required this.totalInternalLoanPrincipal,
    required this.totalInternalLoanInterest,
    required this.totalSofaDisbursed,
    required this.totalSofaRepaid,
    required this.warningEntryCount,
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyles.body),
          ),
          const SizedBox(width: 12),
          Text(formatted, style: AppTextStyles.amount),
        ],
      ),
    );
  }
}
