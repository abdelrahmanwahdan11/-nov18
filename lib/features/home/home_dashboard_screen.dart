import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/controllers/trips_controller.dart';
import '../../core/controllers/vehicle_controller.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../profile/profile_screen.dart';
import '../quick_controls/quick_controls_screen.dart';
import '../trips/trips_list_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.authController,
    required this.vehicleController,
    required this.appController,
    TripsController? tripsController,
  }) : tripsController = tripsController ?? TripsController();

  final AuthController authController;
  final VehicleController vehicleController;
  final AppController appController;
  final TripsController tripsController;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _DashboardView(
        authController: widget.authController,
        vehicleController: widget.vehicleController,
        appController: widget.appController,
      ),
      QuickControlsScreen(authController: widget.authController),
      TripsListScreen(controller: widget.tripsController, embedded: true),
      ProfileScreen(authController: widget.authController, embedded: true),
    ];

    return AppScaffold(
      authController: widget.authController,
      body: AnimatedSwitcher(
        duration: 300.ms,
        child: tabs[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) => setState(() => currentIndex = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(IconlyBold.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.setting), label: 'Controls'),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.location), label: 'Trips'),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.profile), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.authController,
    required this.vehicleController,
    required this.appController,
  });

  final AuthController authController;
  final VehicleController vehicleController;
  final AppController appController;

  @override
  Widget build(BuildContext context) {
    final vehicle = vehicleController.currentVehicle;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello ${authController.user?.name ?? 'Guest'}',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vehicle.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('${vehicle.power} hp · ${vehicle.range} km'),
                        ],
                      ),
                    ),
                    const AiInfoButton(),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(vehicle.image, height: 180, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _QuickAction(icon: IconlyBold.lock, label: 'Locked'),
                    _QuickAction(icon: IconlyBold.moon, label: 'Dark'),
                    _QuickAction(icon: IconlyBold.volume_up, label: 'Honk'),
                    _QuickAction(icon: IconlyBold.setting, label: 'Control'),
                  ],
                ),
              ],
            ),
          ).animate().fade(duration: 400.ms).moveY(begin: 30, end: 0),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Battery status',
            action: Text('${(vehicle.batteryLevel * 100).round()}%'),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: vehicle.batteryLevel,
                  color: appController.primaryColor,
                  backgroundColor:
                      appController.primaryColor.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Charging'),
                    Text('Remaining 320 km'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
