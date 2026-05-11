import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _localeKey = 'app_locale';

const appSupportedLocales = [
  Locale('en'),
  Locale('ta'),
  Locale('ta', 'IN'), // Mixed Tamil/English mode
];

class LocaleNotifier extends StateNotifier<Locale> {
  final FlutterSecureStorage _storage;

  LocaleNotifier(this._storage) : super(const Locale('en'));

  Future<void> loadSaved() async {
    final saved = await _storage.read(key: _localeKey);
    if (saved != null) state = _fromString(saved);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final key = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await _storage.write(key: _localeKey, value: key);
  }

  static Locale _fromString(String code) {
    switch (code) {
      case 'ta_IN':
        return const Locale('ta', 'IN');
      case 'ta':
        return const Locale('ta');
      default:
        return const Locale('en');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  const storage = FlutterSecureStorage();
  return LocaleNotifier(storage)..loadSaved();
});
