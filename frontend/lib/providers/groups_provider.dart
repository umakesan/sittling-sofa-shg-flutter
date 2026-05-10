import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/group.dart';
import 'shared_providers.dart';

class GroupsNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() =>
      ref.read(groupRepositoryProvider).getAll();

  Future<void> refreshFromServer() async {
    final repo = ref.read(groupRepositoryProvider);
    state = const AsyncLoading();
    try {
      state = AsyncData(await repo.refreshFromServer());
    } catch (e, st) {
      final current = state;
      // On native, fall back to data already in local DB.
      if (current is AsyncData<List<Group>> && current.value.isNotEmpty) {
        state = current;
      } else {
        state = AsyncError(e, st);
      }
    }
  }
}

final groupsProvider =
    AsyncNotifierProvider<GroupsNotifier, List<Group>>(GroupsNotifier.new);
