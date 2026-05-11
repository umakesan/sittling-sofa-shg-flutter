import 'package:flutter/material.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_drawer.dart';
import '../widgets/connectivity_bar.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/status_pill.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entriesAsync = ref.watch(entriesProvider);
    final groupsAsync = ref.watch(groupsProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      drawer: isTablet ? null : const AppDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle, style: AppTextStyles.appBarTitle),
            Text(l10n.appSubtitle, style: AppTextStyles.appBarSubtitle),
          ],
        ),
        actions: [
          if (!isTablet)
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: l10n.dashboardTooltip,
              onPressed: () => context.push('/dashboard'),
            ),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(groupsProvider.notifier).refreshFromServer(),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Metric banner
                      entriesAsync.maybeWhen(
                        data: (entries) => _MetricBanner(
                          entries: entries,
                          l10n: l10n,
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      FilledButton.icon(
                        onPressed: () => context.go('/entries/new'),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.newEntry),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          textStyle: AppTextStyles.button,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pending entries section
                      entriesAsync.when(
                        data: (entries) {
                          final pending = entries
                              .where(
                                  (e) => e.syncStatus == SyncStatus.pendingSync)
                              .toList();
                          if (pending.isEmpty) return const SizedBox.shrink();
                          return _Section(
                            title: l10n.pendingSyncCount(pending.length),
                            children: groupsAsync.maybeWhen(
                              data: (groups) {
                                final groupMap = {
                                  for (final g in groups) g.id: g
                                };
                                return pending
                                    .map((e) => _EntryTile(
                                          entry: e,
                                          groupName:
                                              groupMap[e.groupId]?.name ??
                                                  '${l10n.groupLedger} ${e.groupId}',
                                          villageName: groupMap[e.groupId]
                                                  ?.villageName ??
                                              '',
                                        ))
                                    .toList();
                              },
                              orElse: () => [],
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      // Recent entries section
                      _Section(
                        title: l10n.recentEntries,
                        children: entriesAsync.when(
                          loading: () => [
                            const ShimmerCard(height: 68),
                            const ShimmerCard(height: 68),
                            const ShimmerCard(height: 68),
                          ],
                          error: (e, _) => [
                            Text(l10n.couldNotLoadEntries,
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.error))
                          ],
                          data: (entries) {
                            final recent = entries
                                .where(
                                    (e) => e.syncStatus == SyncStatus.synced)
                                .take(8)
                                .toList();
                            if (recent.isEmpty) {
                              return [_EmptyState(l10n: l10n)];
                            }
                            return groupsAsync.maybeWhen(
                              data: (groups) {
                                final groupMap = {
                                  for (final g in groups) g.id: g
                                };
                                return recent
                                    .map((e) => _EntryTile(
                                          entry: e,
                                          groupName:
                                              groupMap[e.groupId]?.name ??
                                                  '${l10n.groupLedger} ${e.groupId}',
                                          villageName: groupMap[e.groupId]
                                                  ?.villageName ??
                                              '',
                                        ))
                                    .toList();
                              },
                              orElse: () => [],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Metric banner ────────────────────────────────────────────────────────────

class _MetricBanner extends StatelessWidget {
  final List<MonthEntry> entries;
  final AppLocalizations l10n;

  const _MetricBanner({required this.entries, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final total = entries.length;
    final pending =
        entries.where((e) => e.syncStatus == SyncStatus.pendingSync).length;
    final thisMonth = entries.where((e) {
      final m = DateTime.parse(e.entryMonth);
      return m.year == now.year && m.month == now.month;
    }).length;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.list_alt_rounded,
            value: '$total',
            label: l10n.metricTotal,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.sync_rounded,
            value: '$pending',
            label: l10n.statusPending,
            iconColor:
                pending > 0 ? AppColors.pending : AppColors.textTertiary,
            highlight: pending > 0,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            icon: Icons.calendar_today_rounded,
            value: '$thisMonth',
            label: l10n.metricThisMonth,
            iconColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final bool highlight;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.pendingBg : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppColors.pendingBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.amountSmall),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.label.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.book_outlined,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noSyncedEntries,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.contactAdmin,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Entry tile ─────────────────────────────────────────────────────────────────

class _EntryTile extends StatelessWidget {
  final MonthEntry entry;
  final String groupName;
  final String villageName;

  const _EntryTile({
    required this.entry,
    required this.groupName,
    required this.villageName,
  });

  @override
  Widget build(BuildContext context) {
    final month =
        DateFormat('MMMM yyyy').format(DateTime.parse(entry.entryMonth));
    final isPending = entry.syncStatus == SyncStatus.pendingSync;
    final hasWarning = entry.warningFlags.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: hasWarning
                ? AppColors.warningIcon
                : isPending
                    ? AppColors.pending
                    : AppColors.syncedBorder,
            width: 3,
          ),
          top: const BorderSide(color: AppColors.border, width: 1),
          right: const BorderSide(color: AppColors.border, width: 1),
          bottom: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/entries/edit', extra: entry),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(groupName, style: AppTextStyles.title),
                    const SizedBox(height: 3),
                    Text(
                      '$villageName · $month',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusPill(
                status: isPending
                    ? EntryStatus.pending
                    : hasWarning
                        ? EntryStatus.savedWithWarnings
                        : EntryStatus.synced,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
