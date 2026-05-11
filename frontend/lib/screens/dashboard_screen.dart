import 'package:flutter/material.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../models/month_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/entries_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/shimmer_loader.dart';

// ─── Formatters ───────────────────────────────────────────────────────────────

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

// ─── Data model ───────────────────────────────────────────────────────────────

class _Summary {
  final double savings;
  final double loanPrincipal;
  final double loanInterest;
  final double sofaDisbursed;
  final double sofaRepaid;
  final int warnings;

  double get totalAsset => savings + loanInterest;

  const _Summary({
    required this.savings,
    required this.loanPrincipal,
    required this.loanInterest,
    required this.sofaDisbursed,
    required this.sofaRepaid,
    required this.warnings,
  });
}

_Summary _summarise(List<MonthEntry> entries) {
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
  return _Summary(
    savings: savings,
    loanPrincipal: principal,
    loanInterest: interest,
    sofaDisbursed: sofa,
    sofaRepaid: sofaRepaid,
    warnings: warnings,
  );
}

// ─── Report catalogue ─────────────────────────────────────────────────────────

class _Report {
  final IconData icon;
  final Color color;
  final String label;
  final String? route;

  const _Report({
    required this.icon,
    required this.color,
    required this.label,
    this.route,
  });
}

List<_Report> _buildReports(AppLocalizations l, AppUser? user) {
  final isManagement = user?.isManagement ?? false;
  final isAdmin = user?.isAdmin ?? false;
  final managementOrAbove = isManagement || isAdmin;

  return [
    // Report 1 — all roles
    _Report(
      icon: Icons.account_balance_wallet_outlined,
      color: AppColors.primary,
      label: l.savingsOverview,
      route: '/reports/savings',
    ),
    // Report 2 — all roles
    _Report(
      icon: Icons.handshake_outlined,
      color: const Color(0xFF0369A1),
      label: l.sofaLoansReport,
      route: '/reports/sofa',
    ),
    // Report 3 — all roles
    _Report(
      icon: Icons.account_balance_outlined,
      color: const Color(0xFF7C3AED),
      label: l.bankFlowReport,
      route: '/reports/bank',
    ),
    // Report 4 — management + admin only
    if (managementOrAbove)
      _Report(
        icon: Icons.compare_arrows_rounded,
        color: const Color(0xFF0D9488),
        label: l.villageCompareReport,
        route: '/reports/compare',
      ),
    // Report 5 — all roles
    _Report(
      icon: Icons.warning_amber_rounded,
      color: AppColors.pending,
      label: l.overdueAlertsReport,
      route: '/reports/overdue',
    ),
    // Report 6 — management + admin only
    if (managementOrAbove)
      _Report(
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF7C3AED),
        label: l.trendsReport,
        route: '/reports/trends',
      ),
    // Report 7 — all roles
    _Report(
      icon: Icons.groups_outlined,
      color: const Color(0xFF0369A1),
      label: l.groupHealthReport,
      route: '/reports/health',
    ),
    // Report 8 — management + admin only
    if (managementOrAbove)
      _Report(
        icon: Icons.percent_rounded,
        color: AppColors.synced,
        label: l.recoveryRateReport,
        route: '/reports/recovery',
      ),
    // Report 9 — admin only
    if (isAdmin)
      _Report(
        icon: Icons.assignment_outlined,
        color: AppColors.textSecondary,
        label: l.auditLogReport,
        route: '/reports/audit',
      ),
  ];
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authProvider);
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
            constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
            child: _buildSkeleton(),
          ),
        ),
        error: (e, _) => Center(
          child: Text('$e',
              style: AppTextStyles.body.copyWith(color: AppColors.error)),
        ),
        data: (entries) {
          final s = _summarise(entries);
          final reports = _buildReports(l10n, user);
          final crossAxisCount = isTablet ? 3 : 2;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // ── 1. Hero ──────────────────────────────────────────────
                  _HeroBanner(summary: s, entryCount: entries.length),
                  const SizedBox(height: 12),

                  // ── 2. Warnings ──────────────────────────────────────────
                  if (s.warnings > 0) ...[
                    _WarningBanner(count: s.warnings),
                    const SizedBox(height: 12),
                  ],

                  // ── 3. Stats grid ────────────────────────────────────────
                  Text(l10n.villageWideTotals,
                      style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 8),
                  _StatsGrid(summary: s, l10n: l10n),
                  const SizedBox(height: 24),

                  // ── 4. Reports ───────────────────────────────────────────
                  Text(l10n.reportsSection.toUpperCase(),
                      style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 12),
                  _ReportsGrid(
                      reports: reports, crossAxisCount: crossAxisCount),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

Widget _buildSkeleton() => ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(height: 120, margin: EdgeInsets.only(bottom: 12)),
        ShimmerCard(height: 18, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 80, margin: EdgeInsets.only(bottom: 10)),
        ShimmerCard(height: 80, margin: EdgeInsets.only(bottom: 10)),
        ShimmerCard(height: 80, margin: EdgeInsets.only(bottom: 24)),
        ShimmerCard(height: 18, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 150),
      ],
    );

// ─── Hero banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final _Summary summary;
  final int entryCount;

  const _HeroBanner({required this.summary, required this.entryCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(
            l10n.totalSavingsAsset.toUpperCase(),
            style: AppTextStyles.sectionHeader
                .copyWith(color: AppColors.textOnDarkMuted),
          ),
          const SizedBox(height: 8),
          Text(
            _fmtCompact(summary.totalAsset),
            style: AppTextStyles.displayLarge
                .copyWith(color: AppColors.textOnDark, height: 1.1),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.basedOnEntries(entryCount),
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textOnDarkMuted),
                ),
              ),
              const SizedBox(width: 8),
              _InfoPill(
                  label: l10n.savingsCorpus,
                  value: _fmtCompact(summary.savings)),
              const SizedBox(width: 6),
              _InfoPill(
                  label: l10n.interestEarned,
                  value: _fmtCompact(summary.loanInterest)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textOnDarkMuted, fontSize: 9),
          ),
          Text(
            value,
            style: AppTextStyles.label.copyWith(
                color: AppColors.textOnDark, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─── Warning banner ───────────────────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  final int count;

  const _WarningBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
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
              l10n.warningEntriesCount(count),
              style: AppTextStyles.body.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final _Summary summary;
  final AppLocalizations l10n;

  const _StatsGrid({required this.summary, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final chips = [
      _StatChip(
        icon: Icons.savings_outlined,
        accentColor: const Color(0xFF166534),
        tintColor: const Color(0xFFDCFCE7),
        label: l10n.savingsCorpus,
        value: summary.savings,
      ),
      _StatChip(
        icon: Icons.trending_up_rounded,
        accentColor: const Color(0xFF0369A1),
        tintColor: const Color(0xFFDBEAFE),
        label: l10n.interestEarned,
        value: summary.loanInterest,
        onTap: () => context.push('/reports/interest'),
      ),
      _StatChip(
        icon: Icons.people_outline,
        accentColor: const Color(0xFF1E40AF),
        tintColor: const Color(0xFFDBEAFE),
        label: l10n.internalLoanPrincipal,
        value: summary.loanPrincipal,
      ),
      _StatChip(
        icon: Icons.arrow_upward_rounded,
        accentColor: const Color(0xFFB45309),
        tintColor: const Color(0xFFFEF3C7),
        label: l10n.sofaLoansDisbursed,
        value: summary.sofaDisbursed,
      ),
      _StatChip(
        icon: Icons.arrow_downward_rounded,
        accentColor: const Color(0xFF0F766E),
        tintColor: const Color(0xFFCCFBF1),
        label: l10n.sofaLoansRepaid,
        value: summary.sofaRepaid,
      ),
    ];

    final isMobile = MediaQuery.sizeOf(context).width < 600;
    if (isMobile) {
      return Column(children: chips);
    }
    final rows = <Widget>[];
    for (int i = 0; i < chips.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 10));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: chips[i]),
            const SizedBox(width: 10),
            if (i + 1 < chips.length)
              Expanded(child: chips[i + 1])
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ));
    }
    return Column(children: rows);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final Color tintColor;
  final String label;
  final double value;
  final VoidCallback? onTap;

  const _StatChip({
    required this.icon,
    required this.accentColor,
    required this.tintColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = _fmtFull(value);
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

// ─── Reports grid ─────────────────────────────────────────────────────────────

class _ReportsGrid extends StatelessWidget {
  final List<_Report> reports;
  final int crossAxisCount;

  const _ReportsGrid({required this.reports, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < reports.length; i += crossAxisCount) {
      if (i > 0) rows.add(const SizedBox(height: 12));
      final slice = reports.skip(i).take(crossAxisCount).toList();
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int j = 0; j < crossAxisCount; j++) ...[
              if (j > 0) const SizedBox(width: 12),
              j < slice.length
                  ? Expanded(child: _ReportTile(report: slice[j]))
                  : const Expanded(child: SizedBox()),
            ],
          ],
        ),
      ));
    }
    return Column(children: rows);
  }
}

class _ReportTile extends StatelessWidget {
  final _Report report;

  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = report.route != null;

    return Opacity(
      opacity: available ? 1.0 : 0.65,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (report.route != null) {
              context.push(report.route!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.comingSoon),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: available
                    ? report.color.withOpacity(0.35)
                    : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: report.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(report.icon, color: report.color, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  report.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!available) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.comingSoon,
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
