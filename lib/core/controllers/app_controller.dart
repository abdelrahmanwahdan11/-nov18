import 'dart:ui';

import 'package:flutter/material.dart';

import '../storage/preferences_service.dart';
import '../theme/app_colors.dart';

class AppController extends ChangeNotifier {
  AppController() {
    _load();
  }

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  Color _primaryColor = AppColors.defaultPrimary;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  Color get primaryColor => _primaryColor;

  Future<void> _load() async {
    final prefs = PreferencesService.instance;
    final themeString = await prefs.getString('themeMode');
    final language = await prefs.getString('language');
    final primary = await prefs.getString('primaryColor');

    if (themeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeString,
        orElse: () => ThemeMode.system,
      );
    }
    if (language != null) {
      _locale = Locale(language);
    }
    if (primary != null) {
      _primaryColor = Color(int.parse(primary));
    }
    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode mode) async {
    _themeMode = mode;
    await PreferencesService.instance.setString('themeMode', mode.name);
    notifyListeners();
  }

  Future<void> changeLocale(Locale locale) async {
    _locale = locale;
    await PreferencesService.instance
        .setString('language', locale.languageCode);
    notifyListeners();
  }

  Future<void> changePrimaryColor(Color color) async {
    _primaryColor = color;
    await PreferencesService.instance
        .setString('primaryColor', color.value.toString());
    notifyListeners();
  }
}
