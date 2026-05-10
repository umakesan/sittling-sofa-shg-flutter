import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/group.dart';
import 'shared_providers.dart';

// Loads groups from local DB. Call refreshGroups() to fetch from server.
class GroupsNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() async {
    final db = ref.read(localDbProvider);
    return db.getGroups();
  }

  Future<void> refreshFromServer() async {
    final db = ref.read(localDbProvider);
    final api = ref.read(apiClientProvider);
    state = const AsyncLoading();
    try {
      final groups = await api.fetchGroups();
      await db.upsertGroups(groups);
      state = AsyncData(groups);
    } catch (e, st) {
      // Fall back to cached data
      final cached = await db.getGroups();
      if (cached.isNotEmpty) {
        state = AsyncData(cached);
      } else {
        state = AsyncError(e, st);
      }
    }
  }
}

final groupsProvider =
    AsyncNotifierProvider<GroupsNotifier, List<Group>>(GroupsNotifier.new);
