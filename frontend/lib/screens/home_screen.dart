import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/month_entry.dart';
import '../providers/entries_provider.dart';
import '../providers/groups_provider.dart';
import '../widgets/sync_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesProvider);
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SHG Portal'),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Dashboard',
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(groupsProvider.notifier).refreshFromServer(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Primary action
            FilledButton.icon(
              onPressed: () => context.go('/entries/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Entry'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
                minimumSize: const Size(double.infinity, 52),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),
            const SyncButton(),
            const SizedBox(height: 24),

            // Pending entries
            entriesAsync.when(
              data: (entries) {
                final pending = entries
                    .where((e) => e.syncStatus == SyncStatus.pendingSync)
                    .toList();
                if (pending.isEmpty) return const SizedBox.shrink();
                return _Section(
                  title: 'Pending sync (${pending.length})',
                  children: groupsAsync.maybeWhen(
                    data: (groups) {
                      final groupMap = {for (final g in groups) g.id: g};
                      return pending
                          .map((e) => _EntryTile(
                                entry: e,
                                groupName: groupMap[e.groupId]?.name ?? 'Group ${e.groupId}',
                                villageName: groupMap[e.groupId]?.villageName ?? '',
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

            // Recent entries
            _Section(
              title: 'Recent entries',
              children: entriesAsync.when(
                loading: () => [
                  const Center(child: CircularProgressIndicator())
                ],
                error: (e, _) => [
                  Text('Could not load entries: $e',
                      style: const TextStyle(color: Colors.red))
                ],
                data: (entries) {
                  final recent = entries
                      .where((e) => e.syncStatus == SyncStatus.synced)
                      .take(8)
                      .toList();
                  if (recent.isEmpty) {
                    return [
                      const Text('No synced entries yet.',
                          style: TextStyle(color: Colors.grey))
                    ];
                  }
                  return groupsAsync.maybeWhen(
                    data: (groups) {
                      final groupMap = {for (final g in groups) g.id: g};
                      return recent
                          .map((e) => _EntryTile(
                                entry: e,
                                groupName: groupMap[e.groupId]?.name ?? 'Group ${e.groupId}',
                                villageName: groupMap[e.groupId]?.villageName ?? '',
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
    );
  }
}

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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }
}

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
    final month = DateFormat('MMMM yyyy').format(DateTime.parse(entry.entryMonth));
    final isPending = entry.syncStatus == SyncStatus.pendingSync;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(groupName),
        subtitle: Text('$villageName · $month'),
        onTap: () => context.push('/entries/edit', extra: entry),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (entry.warningFlags.isNotEmpty)
              const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 4),
            Chip(
              label: Text(isPending ? 'Pending' : 'Synced',
                  style: const TextStyle(fontSize: 11)),
              backgroundColor: isPending
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFD1FAE5),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
