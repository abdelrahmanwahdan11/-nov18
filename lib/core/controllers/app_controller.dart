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
  bool _useMetric = true;
  bool _useCelsius = true;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  Color get primaryColor => _primaryColor;
  bool get useMetric => _useMetric;
  bool get useCelsius => _useCelsius;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> _load() async {
    final prefs = PreferencesService.instance;
    final themeString = await prefs.getString('themeMode');
    final language = await prefs.getString('language');
    final primary = await prefs.getString('primaryColor');
    final metric = await prefs.getBool('metric', defaultValue: true);
    final celsius = await prefs.getBool('celsius', defaultValue: true);
    final notifications =
        await prefs.getBool('notifications', defaultValue: true);

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
    _useMetric = metric;
    _useCelsius = celsius;
    _notificationsEnabled = notifications;
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

  Future<void> toggleMetric(bool value) async {
    _useMetric = value;
    await PreferencesService.instance.setBool('metric', value);
    notifyListeners();
  }

  Future<void> toggleCelsius(bool value) async {
    _useCelsius = value;
    await PreferencesService.instance.setBool('celsius', value);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await PreferencesService.instance.setBool('notifications', value);
    notifyListeners();
  }

  String formatDistance(num kilometers, {bool includeUnit = true}) {
    final value = useMetric
        ? kilometers
        : double.parse((kilometers * 0.621371).toStringAsFixed(1));
    final unit = useMetric ? 'km' : 'mi';
    return includeUnit ? '${value.toStringAsFixed(0)} $unit' : '$value';
  }

  String formatTemperature(num celsius, {bool includeUnit = true}) {
    final unitValue = useCelsius ? celsius : celsius * 1.8 + 32;
    final suffix = useCelsius ? '°C' : '°F';
    return includeUnit
        ? '${unitValue.toStringAsFixed(0)}$suffix'
        : unitValue.toStringAsFixed(0);
  }
}
