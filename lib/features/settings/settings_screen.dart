import 'package:flutter/material.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/localization/app_localizations.dart';
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
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('settings'))),
      body: AnimatedBuilder(
        animation: appController,
        builder: (context, _) {
          final locale = AppLocalizations.of(context);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(locale.translate('language'),
                  style: Theme.of(context).textTheme.titleMedium),
              RadioListTile(
                title: const Text('English'),
                value: 'en',
                groupValue: appController.locale.languageCode,
                onChanged: (value) => appController.changeLocale(const Locale('en')),
              ),
              RadioListTile(
                title: const Text('العربية'),
                value: 'ar',
                groupValue: appController.locale.languageCode,
                onChanged: (value) => appController.changeLocale(const Locale('ar')),
              ),
              const Divider(height: 32),
              Text(locale.translate('theme'),
                  style: Theme.of(context).textTheme.titleMedium),
              RadioListTile(
                title: Text(locale.translate('systemTheme')),
                value: ThemeMode.system,
                groupValue: appController.themeMode,
                onChanged: (mode) => appController.changeTheme(mode!),
              ),
              RadioListTile(
                title: Text(locale.translate('lightTheme')),
                value: ThemeMode.light,
                groupValue: appController.themeMode,
                onChanged: (mode) => appController.changeTheme(mode!),
              ),
              RadioListTile(
                title: Text(locale.translate('darkTheme')),
                value: ThemeMode.dark,
                groupValue: appController.themeMode,
                onChanged: (mode) => appController.changeTheme(mode!),
              ),
              const Divider(height: 32),
              Text(locale.translate('primaryColor'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: palette
                    .map(
                      (color) => GestureDetector(
                        onTap: () => appController.changePrimaryColor(color),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: color,
                          child: appController.primaryColor == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Divider(height: 32),
              Text(locale.translate('units'),
                  style: Theme.of(context).textTheme.titleMedium),
              SwitchListTile(
                title: Text(locale.translate('metricUnits')),
                value: appController.useMetric,
                onChanged: appController.toggleMetric,
              ),
              SwitchListTile(
                title: Text(locale.translate('celsiusUnits')),
                value: appController.useCelsius,
                onChanged: appController.toggleCelsius,
              ),
              const Divider(height: 32),
              Text(locale.translate('notifications'),
                  style: Theme.of(context).textTheme.titleMedium),
              SwitchListTile(
                title: Text(locale.translate('generalNotifications')),
                value: appController.notificationsEnabled,
                onChanged: appController.toggleNotifications,
              ),
              SwitchListTile(
                title: Text(locale.translate('chargingAlerts')),
                value: true,
                onChanged: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Charging alert preferences are stored locally until cloud sync is ready.'),
                    ),
                  );
                },
              ),
              SwitchListTile(
                title: Text(locale.translate('maintenanceReminders')),
                value: true,
                onChanged: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maintenance reminders stay enabled offline.'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
