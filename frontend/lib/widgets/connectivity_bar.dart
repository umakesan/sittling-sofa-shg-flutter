import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_portal/l10n/app_localizations.dart';

import '../providers/connectivity_provider.dart';
import '../providers/entries_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ConnectivityBar extends ConsumerWidget {
  const ConnectivityBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isOnline = ref.watch(isOnlineProvider);
    final pending = ref.watch(pendingCountProvider);

    if (isOnline && pending == 0) return const SizedBox.shrink();

    final bg = isOnline ? AppColors.syncPendingBg : AppColors.offlineBg;
    final icon =
        isOnline ? Icons.cloud_sync_outlined : Icons.wifi_off_rounded;
    final label = isOnline ? l10n.pendingCount(pending) : l10n.offline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
