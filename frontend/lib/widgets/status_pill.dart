import 'package:flutter/material.dart';
import 'package:shg_portal/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum EntryStatus { pending, synced, saved, savedWithWarnings, draft }

class StatusPill extends StatelessWidget {
  final EntryStatus status;

  const StatusPill({super.key, required this.status});

  static StatusPill fromString(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('synced')) return const StatusPill(status: EntryStatus.synced);
    if (lower.contains('warning')) return const StatusPill(status: EntryStatus.savedWithWarnings);
    if (lower.contains('saved')) return const StatusPill(status: EntryStatus.saved);
    if (lower.contains('draft')) return const StatusPill(status: EntryStatus.draft);
    return const StatusPill(status: EntryStatus.pending);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (color, bg, border, label) = _config(l10n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.badge.copyWith(color: color)),
        ],
      ),
    );
  }

  (Color, Color, Color, String) _config(AppLocalizations l10n) {
    return switch (status) {
      EntryStatus.synced => (
          AppColors.synced,
          AppColors.syncedBg,
          AppColors.syncedBorder,
          l10n.statusSynced,
        ),
      EntryStatus.savedWithWarnings => (
          AppColors.primary,
          AppColors.primaryContainer,
          AppColors.border,
          l10n.statusSaved,
        ),
      EntryStatus.saved => (
          AppColors.primary,
          AppColors.primaryContainer,
          AppColors.border,
          l10n.statusSaved,
        ),
      EntryStatus.draft => (
          AppColors.draft,
          AppColors.draftBg,
          AppColors.draftBorder,
          l10n.statusDraft,
        ),
      EntryStatus.pending => (
          AppColors.pending,
          AppColors.pendingBg,
          AppColors.pendingBorder,
          l10n.statusPending,
        ),
    };
  }
}
