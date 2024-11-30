import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A Riverpod `StateNotifier` for managing theme mode.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _themeModeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeFromPreferences();
  }

  /// Load theme mode from local storage (SharedPreferences).
  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString =
        prefs.getString(_themeModeKey) ?? ThemeMode.system.toString();
    state = ThemeMode.values.firstWhere(
      (mode) => mode.toString() == themeString,
      orElse: () => ThemeMode.system,
    );
  }

  /// Save the selected theme mode to local storage.
  Future<void> _saveThemeToPreferences(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }

  /// Update the theme mode and persist it.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _saveThemeToPreferences(mode);
  }
}

/// Riverpod provider for the theme notifier.
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// A computed provider for easier access to theme mode.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeNotifierProvider);
});
