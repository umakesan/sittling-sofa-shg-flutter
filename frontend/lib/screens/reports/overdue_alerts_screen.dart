import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/reports_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/shimmer_loader.dart';

// ─── Helpers ───────────────────────────────────────────────────────────────────

String _fmtMonth(String ym) {
  try {
    return DateFormat('MMM yyyy').format(DateTime.parse(ym));
  } catch (_) {
    return ym;
  }
}

Widget _buildSkeleton() => ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 72, margin: EdgeInsets.only(bottom: 8)),
        ShimmerCard(height: 72),
      ],
    );

// ═══════════════════════════════════════════════════════════════════════════════
// OVERDUE ALERTS SCREEN (1-level — flat list of groups needing attention)
// ═══════════════════════════════════════════════════════════════════════════════

class OverdueAlertsScreen extends ConsumerWidget {
  const OverdueAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final dataAsync = ref.watch(overdueAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.overdueAlertsReport),
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
        data: (alerts) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 768 : 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Summary banner
                  _SummaryBanner(alerts: alerts, l10n: l10n),
                  const SizedBox(height: 20),

                  if (alerts.isEmpty)
                    _AllClearCard(l10n: l10n)
                  else ...[
                    // Overdue section
                    _buildSection(
                      context,
                      alerts: alerts.where((a) => a.isOverdue).toList(),
                      label: 'OVERDUE',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.pending,
                      l10n: l10n,
                    ),
                    if (alerts.any((a) => !a.isOverdue && a.warningCount > 0)) ...[
                      const SizedBox(height: 20),
                      _buildSection(
                        context,
                        alerts: alerts.where((a) => !a.isOverdue && a.warningCount > 0).toList(),
                        label: 'WARNINGS',
                        icon: Icons.info_outline_rounded,
                        color: AppColors.warning,
                        l10n: l10n,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required List<OverdueAlert> alerts,
    required String label,
    required IconData icon,
    required Color color,
    required AppLocalizations l10n,
  }) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.sectionHeader.copyWith(color: color)),
        ]),
        const SizedBox(height: 8),
        ...alerts.map((a) => _AlertCard(alert: a, l10n: l10n)),
      ],
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final List<OverdueAlert> alerts;
  final AppLocalizations l10n;

  const _SummaryBanner({required this.alerts, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final overdueCount = alerts.where((a) => a.isOverdue).length;
    final warningCount = alerts.where((a) => a.warningCount > 0).length;

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warningIcon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${alerts.length} group${alerts.length == 1 ? '' : 's'} need attention',
                    style: AppTextStyles.title.copyWith(color: AppColors.warning)),
                const SizedBox(height: 4),
                Text(
                  '$overdueCount overdue  ·  $warningCount with warnings',
                  style: AppTextStyles.label.copyWith(color: AppColors.warning),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllClearCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _AllClearCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.syncedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.syncedBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.synced, size: 48),
          const SizedBox(height: 12),
          Text(l10n.noAlerts,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(color: AppColors.synced)),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final OverdueAlert alert;
  final AppLocalizations l10n;

  const _AlertCard({required this.alert, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isOverdue = alert.isOverdue;
    final borderColor = isOverdue ? AppColors.errorBorder : AppColors.warningBorder;
    final bgColor = isOverdue ? AppColors.errorBg : AppColors.warningBg;
    final accentColor = isOverdue ? AppColors.error : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOverdue ? AppColors.errorBorder : AppColors.warningBorder,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOverdue ? Icons.schedule_rounded : Icons.warning_outlined,
              size: 20,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.group.name, style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  alert.group.villageName,
                  style: AppTextStyles.label.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.errorBorder,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('OVERDUE',
                      style: AppTextStyles.sectionHeader.copyWith(color: AppColors.error)),
                ),
              if (alert.warningCount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.warningsCount(alert.warningCount),
                  style: AppTextStyles.label.copyWith(color: AppColors.warning),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                alert.lastEntryMonth != null
                    ? 'Last: ${_fmtMonth(alert.lastEntryMonth!)}'
                    : 'No entries',
                style: AppTextStyles.label.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
