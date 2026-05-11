import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reports_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/shimmer_loader.dart';

// ─── Formatters ────────────────────────────────────────────────────────────────

String _fmtMonth(String ym) {
  try {
    return DateFormat('MMM yyyy').format(DateTime.parse(ym));
  } catch (_) {
    return ym;
  }
}

String _fmtDate(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);

Widget _buildSkeleton() => ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(height: 80, margin: EdgeInsets.only(bottom: 12)),
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
// LEVEL 1 — FEDERATION (village audit overview, admin only)
// ═══════════════════════════════════════════════════════════════════════════════

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final user = ref.watch(authProvider);
    final dataAsync = ref.watch(villageAuditProvider);

    // Gate: admin only
    if (user == null || !user.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.auditLogReport),
          leading: context.canPop() ? BackButton(onPressed: () => context.pop()) : null,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text(l10n.contactAdmin, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.auditLogReport),
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
          final totalPending = villages.fold(0, (s, v) => s + v.pendingEntries);
          final totalWarnings = villages.fold(0, (s, v) => s + v.warningEntries);
          final totalMissing = villages.fold(0, (s, v) => s + v.totalMissingMonths);
          final totalGroups = villages.fold(0, (s, v) => s + v.totalGroups);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Summary banner
                  _AuditSummaryCard(
                    totalGroups: totalGroups,
                    pendingSync: totalPending,
                    warnings: totalWarnings,
                    missingMonths: totalMissing,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 20),

                  Text(l10n.villagesCount(villages.length).toUpperCase(),
                      style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 8),

                  if (villages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(child: Text(l10n.noEntriesYet, style: AppTextStyles.bodySecondary)),
                    )
                  else
                    ...villages.map((v) => _VillageAuditTile(
                          summary: v,
                          l10n: l10n,
                          onTap: () => context.push('/reports/audit/village/${Uri.encodeComponent(v.villageName)}'),
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

class _AuditSummaryCard extends StatelessWidget {
  final int totalGroups;
  final int pendingSync;
  final int warnings;
  final int missingMonths;
  final AppLocalizations l10n;

  const _AuditSummaryCard({
    required this.totalGroups,
    required this.pendingSync,
    required this.warnings,
    required this.missingMonths,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasIssues = pendingSync > 0 || warnings > 0 || missingMonths > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasIssues ? AppColors.warningBg : AppColors.syncedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasIssues ? AppColors.warningBorder : AppColors.syncedBorder),
      ),
      child: Row(
        children: [
          Icon(
            hasIssues ? Icons.assignment_late_outlined : Icons.assignment_turned_in_outlined,
            color: hasIssues ? AppColors.warningIcon : AppColors.synced,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.groupsCount(totalGroups)} across ${l10n.villagesCount(0).replaceAll('0 villages', 'all villages').replaceAll('0 village', 'all villages')}',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  children: [
                    _MetricBadge(
                      icon: Icons.sync_problem_outlined,
                      label: '$pendingSync pending sync',
                      color: pendingSync > 0 ? AppColors.pending : AppColors.textTertiary,
                    ),
                    _MetricBadge(
                      icon: Icons.warning_amber_outlined,
                      label: '$warnings warnings',
                      color: warnings > 0 ? AppColors.warning : AppColors.textTertiary,
                    ),
                    _MetricBadge(
                      icon: Icons.event_busy_outlined,
                      label: '$missingMonths missing months',
                      color: missingMonths > 0 ? AppColors.pending : AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.label.copyWith(color: color)),
      ],
    );
  }
}

class _VillageAuditTile extends StatelessWidget {
  final VillageAuditSummary summary;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _VillageAuditTile({required this.summary, required this.l10n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasIssues = summary.pendingEntries > 0 || summary.warningEntries > 0 || summary.totalMissingMonths > 0;
    final borderColor = hasIssues ? AppColors.warningBorder : AppColors.border;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
                color: hasIssues ? AppColors.warningBg : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasIssues ? Icons.location_city_rounded : Icons.location_city_rounded,
                size: 20,
                color: hasIssues ? AppColors.warningIcon : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(summary.villageName, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    children: [
                      if (summary.pendingEntries > 0)
                        Text('${summary.pendingEntries} pending',
                            style: AppTextStyles.label.copyWith(color: AppColors.pending)),
                      if (summary.warningEntries > 0)
                        Text('${summary.warningEntries} warnings',
                            style: AppTextStyles.label.copyWith(color: AppColors.warning)),
                      if (summary.totalMissingMonths > 0)
                        Text('${summary.totalMissingMonths} missing',
                            style: AppTextStyles.label.copyWith(color: AppColors.pending)),
                      if (!hasIssues)
                        Text('All clear', style: AppTextStyles.label.copyWith(color: AppColors.synced)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(l10n.groupsCount(summary.totalGroups),
                style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEVEL 2 — VILLAGE (group-level audit detail)
// ═══════════════════════════════════════════════════════════════════════════════

class VillageAuditScreen extends ConsumerWidget {
  final String villageName;
  const VillageAuditScreen({super.key, required this.villageName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(groupAuditProvider(villageName));

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

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text(l10n.groupsCount(groups.length).toUpperCase(), style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 8),
                  ...groups.map((g) => _GroupAuditCard(record: g, l10n: l10n)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupAuditCard extends StatelessWidget {
  final GroupAuditRecord record;
  final AppLocalizations l10n;

  const _GroupAuditCard({required this.record, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final hasIssues = record.pendingSync > 0 || record.warningCount > 0 || record.missingMonths > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasIssues ? AppColors.warningBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(children: [
            Expanded(child: Text(record.group.name, style: AppTextStyles.title)),
            if (hasIssues)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('NEEDS ATTENTION',
                    style: AppTextStyles.sectionHeader.copyWith(color: AppColors.warning)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.syncedBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('OK',
                    style: AppTextStyles.sectionHeader.copyWith(color: AppColors.synced)),
              ),
          ]),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),

          // Stats grid
          Row(children: [
            _AuditStat(
              label: 'Total entries',
              value: '${record.totalEntries}',
              color: AppColors.textSecondary,
            ),
            _AuditStat(
              label: l10n.missingMonths,
              value: record.missingMonths > 0 ? '${record.missingMonths}' : '—',
              color: record.missingMonths > 0 ? AppColors.pending : AppColors.textTertiary,
            ),
            _AuditStat(
              label: 'Pending sync',
              value: record.pendingSync > 0 ? '${record.pendingSync}' : '—',
              color: record.pendingSync > 0 ? AppColors.pending : AppColors.textTertiary,
            ),
            _AuditStat(
              label: 'Warnings',
              value: record.warningCount > 0 ? '${record.warningCount}' : '—',
              color: record.warningCount > 0 ? AppColors.warning : AppColors.textTertiary,
            ),
          ]),

          if (record.lastEntryMonth != null || record.lastUpdated != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (record.lastEntryMonth != null) ...[
                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text('Last: ${_fmtMonth(record.lastEntryMonth!)}',
                      style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
                ],
                if (record.lastUpdated != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.update_outlined, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text('Updated: ${_fmtDate(record.lastUpdated!)}',
                      style: AppTextStyles.label.copyWith(color: AppColors.textTertiary)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AuditStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AuditStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.amountSmall.copyWith(color: color)),
          Text(label, style: AppTextStyles.label.copyWith(color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
