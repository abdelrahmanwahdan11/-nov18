import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/controllers/app_controller.dart';
import '../core/controllers/auth_controller.dart';
import '../core/controllers/catalog_controller.dart';
import '../core/controllers/trips_controller.dart';
import '../core/controllers/vehicle_controller.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';

class EVSmartApp extends StatefulWidget {
  const EVSmartApp({super.key});

  @override
  State<EVSmartApp> createState() => _EVSmartAppState();
}

class _EVSmartAppState extends State<EVSmartApp> {
  late final AppController appController;
  late final AuthController authController;
  late final VehicleController vehicleController;
  late final TripsController tripsController;
  late final CatalogController catalogController;
  late final AppRouter router;

  @override
  void initState() {
    super.initState();
    appController = AppController();
    authController = AuthController();
    vehicleController = VehicleController();
    tripsController = TripsController()..load();
    catalogController = CatalogController()..load();
    router = AppRouter(
      authController: authController,
      vehicleController: vehicleController,
      tripsController: tripsController,
      catalogController: catalogController,
      appController: appController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appController,
      builder: (context, _) {
        final theme = AppTheme(primaryColor: appController.primaryColor);
        return MaterialApp(
          title: 'EV Smart Companion',
          debugShowCheckedModeBanner: false,
          locale: appController.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: appController.themeMode,
          onGenerateRoute: router.onGenerateRoute,
        );
      },
    );
  }
}
