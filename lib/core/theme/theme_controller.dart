import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class ThemeController extends ChangeNotifier {
  ThemeController(SharedPreferencesAsync preferences)
    : _preferences = preferences;

  ThemeController.transient({ThemeMode initialMode = ThemeMode.system})
    : _preferences = null,
      _mode = initialMode;

  static const _preferenceKey = 'theme_mode';

  final SharedPreferencesAsync? _preferences;
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    try {
      final storedMode = await preferences.getString(_preferenceKey);
      _mode = switch (storedMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } on Object {
      _mode = ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) {
      return;
    }

    _mode = mode;
    notifyListeners();

    try {
      await _preferences?.setString(_preferenceKey, mode.name);
    } on Object {
      // The selected mode still applies for the current session.
    }
  }
}
