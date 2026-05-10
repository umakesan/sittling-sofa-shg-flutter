import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'shared_providers.dart';

// ---------------------------------------------------------------------------
// State notifier — holds the current signed-in user (null = not signed in)
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AppUser?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);

  Future<void> tryRestoreSession() async {
    state = await _authService.restoreSession();
  }

  Future<void> login(String userId, String password) async {
    state = await _authService.login(userId, password);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// ---------------------------------------------------------------------------
// Thin ChangeNotifier bridge — used by GoRouter as refreshListenable so the
// router re-evaluates its redirect when auth state changes.
// ---------------------------------------------------------------------------

class RouterAuthNotifier extends ChangeNotifier {
  RouterAuthNotifier(Ref ref) {
    ref.listen<AppUser?>(authProvider, (_, __) => notifyListeners());
  }
}

final routerAuthNotifierProvider = Provider<RouterAuthNotifier>((ref) {
  return RouterAuthNotifier(ref);
});
