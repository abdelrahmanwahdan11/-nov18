import 'package:flutter/material.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.appController});

  final AppController appController;

  @override
  Widget build(BuildContext context) {
    final palette = [
      AppColors.defaultPrimary,
      const Color(0xFF0D9488),
      const Color(0xFF6D28D9),
      const Color(0xFFE11D48),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AnimatedBuilder(
        animation: appController,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('Language'),
              RadioListTile(
                title: const Text('English'),
                value: 'en',
                groupValue: appController.locale.languageCode,
                onChanged: (value) => appController.changeLocale(const Locale('en')),
              ),
              RadioListTile(
                title: const Text('Arabic'),
                value: 'ar',
                groupValue: appController.locale.languageCode,
                onChanged: (value) => appController.changeLocale(const Locale('ar')),
              ),
              const Divider(),
              const Text('Theme'),
              RadioListTile(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: appController.themeMode,
                onChanged: (mode) => appController.changeTheme(mode!),
              ),
              RadioListTile(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: appController.themeMode,
                onChanged: (mode) => appController.changeTheme(mode!),
              ),
              RadioListTile(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: appController.themeMode,
                onChanged: (mode) => appController.changeTheme(mode!),
              ),
              const Divider(),
              const Text('Primary color'),
              Wrap(
                spacing: 12,
                children: palette
                    .map(
                      (color) => GestureDetector(
                        onTap: () => appController.changePrimaryColor(color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          child: appController.primaryColor == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Use metric units'),
                value: true,
                onChanged: (_) {},
              ),
              SwitchListTile(
                title: const Text('Celsius temperature'),
                value: true,
                onChanged: (_) {},
              ),
              SwitchListTile(
                title: const Text('Notifications'),
                value: true,
                onChanged: (_) {},
              ),
            ],
          );
        },
      ),
    );
  }
}
