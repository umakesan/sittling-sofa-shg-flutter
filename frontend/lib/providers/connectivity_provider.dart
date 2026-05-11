import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    StreamProvider<List<ConnectivityResult>>((ref) async* {
  final initial = await Connectivity().checkConnectivity();
  yield initial;
  yield* Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        data: (results) => results.any((r) => r != ConnectivityResult.none),
        orElse: () => true,
      );
});
