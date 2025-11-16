import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/routes.dart';
import '../controllers/auth_controller.dart';
import '../localization/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.authController, this.onNavigate});

  final AuthController authController;
  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final user = authController.user;
    final locale = AppLocalizations.of(context);
    final entries = [
      (locale.translate('dashboard'), IconlyBold.home, AppRoutes.home),
      (locale.translate('globalSearch'), IconlyBold.search, AppRoutes.globalSearch),
      (locale.translate('quickControls'), IconlyBold.setting, AppRoutes.quick),
      (locale.translate('energy'), IconlyBold.sun, AppRoutes.energy),
      (locale.translate('stations'), IconlyBold.location, AppRoutes.stations),
      (locale.translate('trips'), IconlyBold.discovery, AppRoutes.trips),
      (locale.translate('maintenance'), IconlyBold.activity, AppRoutes.maintenance),
      (locale.translate('catalog'), IconlyBold.bag, AppRoutes.catalog),
      (locale.translate('notifications'), IconlyBold.notification, AppRoutes.notifications),
      (locale.translate('settings'), IconlyBold.setting, AppRoutes.settings),
      (locale.translate('help'), IconlyBold.info_circle, AppRoutes.help),
    ];

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user?.avatarUrl ??
                    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=200&q=60'),
                radius: 28,
              ),
              title: Text(user?.name ?? 'Guest Driver'),
              subtitle: Text(user?.email ?? 'guest@evsmart.app'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: Icon(entry.$2),
                    title: Text(entry.$1),
                    onTap: () => onNavigate?.call(entry.$3),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(locale.translate('logout')),
              onTap: authController.logout,
            ),
          ],
        ),
      ),
    );
  }
}
