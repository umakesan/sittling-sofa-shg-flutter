import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../database/local_db.dart';
import '../models/app_user.dart';
import '../models/month_entry.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final ApiClient _api;
  final LocalDb? _db;
  final FlutterSecureStorage _storage;

  AuthService({required ApiClient api, LocalDb? db})
      : _api = api,
        _db = db,
        _storage = const FlutterSecureStorage();

  // Called on app start — restores session from secure storage if still valid.
  Future<AppUser?> restoreSession() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final userJson = await _storage.read(key: 'current_user');
      if (token == null || userJson == null) return null;

      // Decode JWT payload without verifying signature (client-side only)
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;

      final exp = payload['exp'] as int?;
      if (exp != null &&
          DateTime.fromMillisecondsSinceEpoch(exp * 1000).isBefore(DateTime.now())) {
        await _clearSession();
        return null;
      }

      final user = AppUser.fromJsonString(userJson);
      // Fire-and-forget background sync so local DB stays fresh on each app open.
      // Non-blocking — UI loads instantly from local DB, sync updates it silently.
      _syncInBackground();
      return user;
    } catch (_) {
      return null;
    }
  }

  void _syncInBackground() {
    _initialSync(); // intentionally not awaited
  }

  Future<AppUser> login(String userId, String password) async {
    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (isOnline) {
      return _loginOnline(userId, password);
    } else {
      return _loginOffline(userId, password);
    }
  }

  Future<void> logout() async {
    await _clearSession();
  }

  // ---------------------------------------------------------------------------

  Future<AppUser> _loginOnline(String userId, String password) async {
    try {
      final result = await _api.login(userId, password);
      await _api.saveToken(result.token);
      await _storage.write(key: 'current_user', value: result.user.toJsonString());
      if (_db != null) {
        await _db.upsertUserCache(result.user, _hashPassword(userId, password));
        await _initialSync();
      }
      return result.user;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  Future<AppUser> _loginOffline(String userId, String password) async {
    if (_db == null) {
      throw const AuthException(
        'Offline login is not supported on web. Please connect to the internet.',
      );
    }
    final cached = await _db.getCachedUser(userId);
    if (cached == null) {
      throw const AuthException(
        'No cached credentials found. Please connect to the internet and log in first.',
      );
    }
    if (_hashPassword(userId, password) != cached.passwordHash) {
      throw const AuthException('Invalid user ID or password.');
    }
    return cached.user;
  }

  // Downloads groups and entries from server into local DB.
  Future<void> _initialSync() async {
    if (_db == null) return;
    try {
      final groups = await _api.fetchGroups();
      await _db.upsertGroups(groups);

      final rawEntries = await _api.fetchEntries();
      final entries = rawEntries.map(MonthEntry.fromServerJson).toList();
      await _db.upsertServerEntries(entries);
    } catch (_) {
      // Sync failure is non-fatal — user can still proceed
    }
  }

  Future<void> _clearSession() async {
    await _api.clearToken();
    await _storage.delete(key: 'current_user');
  }

  String _hashPassword(String userId, String password) {
    final bytes = utf8.encode('$userId:$password');
    return sha256.convert(bytes).toString();
  }
}
