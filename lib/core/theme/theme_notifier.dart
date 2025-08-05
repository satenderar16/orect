import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'util.dart';


// Use Flutter's built-in ThemeMode directly
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Store your MaterialTheme or create it here (maybe pass fonts or settings via constructor)
  final MaterialTheme materialTheme = MaterialTheme(createTextTheme("Poppins", "Baloo 2"));

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode');
    if (themeString != null) {
      state = _fromString(themeString);
    }
  }

  void setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_mode', _toString(mode));
  }

  ThemeData get currentThemeData {
    switch (state) {
      case ThemeMode.light:
        return materialTheme.light();
      case ThemeMode.dark:
        return materialTheme.dark();
      default:
        return materialTheme.light(); // or decide default system fallback
    }
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  ThemeMode _fromString(String str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';

      default:
        return 'system';
    }
  }
  MaterialTheme get  getMaterialTheme =>materialTheme;
}
