import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/controllers/activity_controller.dart';
import '../core/controllers/app_controller.dart';
import '../core/controllers/auth_controller.dart';
import '../core/controllers/catalog_controller.dart';
import '../core/controllers/diagnostics_controller.dart';
import '../core/controllers/insights_controller.dart';
import '../core/controllers/trips_controller.dart';
import '../core/controllers/vehicle_controller.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';
import 'routes.dart';

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
  late final ActivityController activityController;
  late final InsightsController insightsController;
  late final DiagnosticsController diagnosticsController;
  late final AppRouter router;

  @override
  void initState() {
    super.initState();
    appController = AppController();
    authController = AuthController();
    vehicleController = VehicleController();
    tripsController = TripsController()..load();
    catalogController = CatalogController()..load();
    activityController = ActivityController();
    insightsController = InsightsController();
    diagnosticsController = DiagnosticsController();
    router = AppRouter(
      authController: authController,
      vehicleController: vehicleController,
      tripsController: tripsController,
      catalogController: catalogController,
      appController: appController,
      activityController: activityController,
      insightsController: insightsController,
      diagnosticsController: diagnosticsController,
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
          initialRoute: AppRoutes.splash,
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
