import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../database/local_db.dart';
import '../repositories/entry_repository.dart';
import '../repositories/group_repository.dart';
import '../services/auth_service.dart';

// Set via --dart-define-from-file=.env.json at build/run time.
// Defaults to localhost for local development.
const _apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8000',
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(baseUrl: _apiUrl));

// Only instantiated on native — Riverpod providers are lazy.
final localDbProvider = Provider<LocalDb>((ref) {
  final db = LocalDb();
  ref.onDispose(db.close);
  return db;
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final api = ref.read(apiClientProvider);
  if (kIsWeb) return ApiGroupRepository(api: api);
  return LocalGroupRepository(db: ref.read(localDbProvider), api: api);
});

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  final api = ref.read(apiClientProvider);
  if (kIsWeb) return ApiEntryRepository(api: api);
  return LocalEntryRepository(db: ref.read(localDbProvider), api: api);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    api: ref.read(apiClientProvider),
    db: kIsWeb ? null : ref.read(localDbProvider),
  );
});
