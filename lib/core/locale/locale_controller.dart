import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-selected locale persisted to SharedPreferences. Null = follow system.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _restore();
  }

  static const _key = 'app_locale';
  static const supported = [Locale('en'), Locale('ha')];

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) {
      state = Locale(code);
    }
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController();
});
