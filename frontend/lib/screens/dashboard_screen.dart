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
              accentColor: const Color(0xFF166534),
              tintColor: const Color(0xFFDCFCE7),
              label: l10n.totalSavingsCollected,
              value: summary.totalSavingsCollected,
            ),
            _StatCard(
              icon: Icons.people_outline,
              accentColor: const Color(0xFF1E40AF),
              tintColor: const Color(0xFFDBEAFE),
              label: l10n.internalLoanPrincipal,
              value: summary.totalInternalLoanPrincipal,
            ),
            _StatCard(
              icon: Icons.percent_rounded,
              accentColor: const Color(0xFF6D28D9),
              tintColor: const Color(0xFFEDE9FE),
              label: l10n.internalLoanInterest,
              value: summary.totalInternalLoanInterest,
              onTap: () => context.push('/reports/interest'),
            ),
            _StatCard(
              icon: Icons.arrow_upward_rounded,
              accentColor: const Color(0xFFB45309),
              tintColor: const Color(0xFFFEF3C7),
              label: l10n.sofaLoansDisbursed,
              value: summary.totalSofaDisbursed,
            ),
            _StatCard(
              icon: Icons.arrow_downward_rounded,
              accentColor: const Color(0xFF0F766E),
              tintColor: const Color(0xFFCCFBF1),
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
    for (final e in entries) {
      savings += e.savingsCollected;
      principal += e.internalLoanPrincipalDisbursed;
      interest += e.internalLoanInterestCollected;
      sofa += e.sofaLoanDisbursed;
      sofaRepaid += e.sofaLoanRepayment;
    }
    return _DashboardSummary(
      totalSavingsCollected: savings,
      totalInternalLoanPrincipal: principal,
      totalInternalLoanInterest: interest,
      totalSofaDisbursed: sofa,
      totalSofaRepaid: sofaRepaid,
    );
  }
}

class _DashboardSummary {
  final double totalSavingsCollected;
  final double totalInternalLoanPrincipal;
  final double totalInternalLoanInterest;
  final double totalSofaDisbursed;
  final double totalSofaRepaid;

  const _DashboardSummary({
    required this.totalSavingsCollected,
    required this.totalInternalLoanPrincipal,
    required this.totalInternalLoanInterest,
    required this.totalSofaDisbursed,
    required this.totalSofaRepaid,
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final Color tintColor;
  final String label;
  final double value;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.accentColor,
    required this.tintColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);

    final chip = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tintColor, AppColors.surfaceCard],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
          top: BorderSide(color: accentColor.withOpacity(0.15), width: 1),
          right: BorderSide(color: accentColor.withOpacity(0.15), width: 1),
          bottom: BorderSide(color: accentColor.withOpacity(0.15), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatted,
              style: AppTextStyles.amount.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return chip;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: chip,
      ),
    );
  }
}
