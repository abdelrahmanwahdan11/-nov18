import 'package:flutter/material.dart';

import '../core/controllers/app_controller.dart';
import '../core/controllers/auth_controller.dart';
import '../core/controllers/catalog_controller.dart';
import '../core/controllers/trips_controller.dart';
import '../core/controllers/vehicle_controller.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/verify_code_screen.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/catalog/compare_screen.dart';
import '../features/charging/charging_screen.dart';
import '../features/energy/energy_overview_screen.dart';
import '../features/home/home_dashboard_screen.dart';
import '../features/maintenance/maintenance_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/quick_controls/quick_controls_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stations/station_details_screen.dart';
import '../features/stations/stations_list_screen.dart';
import '../features/trips/trip_details_screen.dart';
import '../features/trips/trips_list_screen.dart';
import 'routes.dart';

class AppRouter {
  AppRouter({
    required this.authController,
    required this.vehicleController,
    required this.tripsController,
    required this.catalogController,
    required this.appController,
  });

  final AuthController authController;
  final VehicleController vehicleController;
  final TripsController tripsController;
  final CatalogController catalogController;
  final AppController appController;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(authController: authController),
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(authController: authController),
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(),
        );
      case AppRoutes.verify:
        return MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(),
        );
      case AppRoutes.forgot:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomeDashboardScreen(
            authController: authController,
            vehicleController: vehicleController,
            appController: appController,
            tripsController: tripsController,
          ),
        );
      case AppRoutes.quick:
        return MaterialPageRoute(
          builder: (_) => QuickControlsScreen(authController: authController),
        );
      case AppRoutes.energy:
        return MaterialPageRoute(
          builder: (_) => const EnergyOverviewScreen(),
        );
      case AppRoutes.charging:
        return MaterialPageRoute(
          builder: (_) => const ChargingScreen(),
        );
      case AppRoutes.stations:
        return MaterialPageRoute(
          builder: (_) => StationsListScreen(controller: catalogController),
        );
      case AppRoutes.stationDetails:
        return MaterialPageRoute(
          builder: (_) => const StationDetailsScreen(),
        );
      case AppRoutes.trips:
        return MaterialPageRoute(
          builder: (_) => TripsListScreen(controller: tripsController),
        );
      case AppRoutes.tripDetails:
        return MaterialPageRoute(
          builder: (_) => const TripDetailsScreen(),
        );
      case AppRoutes.maintenance:
        return MaterialPageRoute(
          builder: (_) => const MaintenanceScreen(),
        );
      case AppRoutes.catalog:
        return MaterialPageRoute(
          builder: (_) => CatalogScreen(controller: catalogController),
        );
      case AppRoutes.compare:
        return MaterialPageRoute(
          builder: (_) => CompareScreen(controller: catalogController),
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(authController: authController),
        );
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(appController: appController),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );
      case AppRoutes.splash:
      default:
        return MaterialPageRoute(
          builder: (_) => HomeDashboardScreen(
            authController: authController,
            vehicleController: vehicleController,
            appController: appController,
            tripsController: tripsController,
          ),
        );
    }
  }
}
