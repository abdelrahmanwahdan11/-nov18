import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  final Color primaryColor;

  const AppTheme({this.primaryColor = AppColors.defaultPrimary});

  ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor.withOpacity(.8),
        surface: AppColors.lightCard,
      ),
      cardColor: AppColors.lightCard,
      textTheme: AppTypography.textTheme(AppColors.textPrimaryLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBackground,
        selectedColor: primaryColor.withOpacity(.15),
        labelStyle: const TextStyle(color: AppColors.textPrimaryLight),
      ),
      useMaterial3: true,
    );
  }

  ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor.withOpacity(.7),
        surface: AppColors.darkCard,
      ),
      cardColor: AppColors.darkCard,
      textTheme: AppTypography.textTheme(AppColors.textPrimaryDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: primaryColor.withOpacity(.25),
        labelStyle: const TextStyle(color: AppColors.textPrimaryDark),
      ),
      useMaterial3: true,
    );
  }
}
