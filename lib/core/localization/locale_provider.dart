import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_translations.dart';

const String _kLanguageKey = 'selected_language';

class LocaleNotifier extends StateNotifier<Locale> {
  final FlutterSecureStorage _storage;

  LocaleNotifier(this._storage) : super(const Locale('th')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final savedLang = await _storage.read(key: _kLanguageKey);
      if (savedLang != null && (savedLang == 'en' || savedLang == 'th')) {
        state = Locale(savedLang);
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    try {
      await _storage.write(key: _kLanguageKey, value: locale.languageCode);
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final nextLang = (state.languageCode == 'th') ? const Locale('en') : const Locale('th');
    await setLocale(nextLang);
  }
}

final storageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(storageProvider);
  return LocaleNotifier(storage);
});

final appTranslationsProvider = Provider<AppTranslations>((ref) {
  final locale = ref.watch(localeProvider);
  return AppTranslations(locale);
});

extension TranslationExtension on BuildContext {
  AppTranslations get tr => AppTranslations(
        Localizations.maybeLocaleOf(this) ?? const Locale('th'),
      );
}

