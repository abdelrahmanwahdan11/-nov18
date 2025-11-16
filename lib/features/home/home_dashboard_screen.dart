import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../app/routes.dart';
import '../../core/controllers/activity_controller.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/controllers/coach_controller.dart';
import '../../core/controllers/diagnostics_controller.dart';
import '../../core/controllers/insights_controller.dart';
import '../../core/controllers/journey_controller.dart';
import '../../core/controllers/trips_controller.dart';
import '../../core/controllers/vehicle_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/activity_entry.dart';
import '../../core/models/driving_tip.dart';
import '../../core/models/insight.dart';
import '../../core/models/journey_plan.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/primary_button.dart';
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
    required this.activityController,
    required this.insightsController,
    required this.diagnosticsController,
    required this.coachController,
    required this.journeyController,
  }) : tripsController = tripsController ?? TripsController();

  final AuthController authController;
  final VehicleController vehicleController;
  final AppController appController;
  final TripsController tripsController;
  final ActivityController activityController;
  final InsightsController insightsController;
  final DiagnosticsController diagnosticsController;
  final CoachController coachController;
  final JourneyController journeyController;

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
        tripsController: widget.tripsController,
        activityController: widget.activityController,
        insightsController: widget.insightsController,
        diagnosticsController: widget.diagnosticsController,
        coachController: widget.coachController,
        journeyController: widget.journeyController,
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

  void _showJourneyNote(BuildContext context, String note) {
    final locale = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.translate('journeyPlanner'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(note),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(locale.translate('close')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.authController,
    required this.vehicleController,
    required this.appController,
    required this.tripsController,
    required this.activityController,
    required this.insightsController,
    required this.diagnosticsController,
    required this.coachController,
    required this.journeyController,
  });

  final AuthController authController;
  final VehicleController vehicleController;
  final AppController appController;
  final TripsController tripsController;
  final ActivityController activityController;
  final InsightsController insightsController;
  final DiagnosticsController diagnosticsController;
  final CoachController coachController;
  final JourneyController journeyController;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([
        vehicleController,
        appController,
        activityController,
        insightsController,
        diagnosticsController,
        coachController,
        journeyController,
      ]),
      builder: (context, _) {
        final vehicle = vehicleController.currentVehicle;
        final vehicles = vehicleController.vehicles;
        final greeting = authController.user?.name ?? 'Guest';
        final upcomingTrip = tripsController.nextTrip;
        final timeline = activityController.recentEntries();
        final insights = insightsController.highlights;
        final diagnostics = diagnosticsController.reports;
        final coachHighlights = coachController.highlightTips();
        final journeyHighlights = journeyController.featuredPlans();
        final nextJourney = journeyController.nextJourney;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                        Text('Hello $greeting',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'Your ${vehicle.name} is ready for the next intelligent drive.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.globalSearch);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _VehicleCard(
                vehicleController: vehicleController,
                appController: appController,
              ),
              const SizedBox(height: 16),
              if (diagnostics.isNotEmpty) ...[
                SectionHeader(
                  title: locale.translate('vehicleHealth'),
                  action: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.diagnostics),
                    child: Text(locale.translate('viewDiagnostics')),
                  ),
                ),
                const SizedBox(height: 12),
                _DiagnosticsPreview(
                  controller: diagnosticsController,
                  locale: locale,
                ),
                const SizedBox(height: 16),
              ],
              SectionHeader(
                title: locale.translate('garage'),
                action: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.garage),
                  child: Text(locale.translate('garageManage')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = vehicles[index];
                    final selected =
                        index == vehicleController.selectedIndex;
                    return SizedBox(
                      width: 210,
                      child: AppCard(
                        child: InkWell(
                          onTap: () => vehicleController.selectVehicle(index),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      item.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                    onPressed: () => vehicleController
                                        .toggleFavorite(item.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appController
                                    .formatDistance(item.range.toDouble()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              LinearProgressIndicator(
                                value: item.batteryLevel,
                                minHeight: 6,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selected
                                    ? locale.translate('primaryVehicle')
                                    : locale.translate('setPrimary'),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: selected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (insights.isNotEmpty) ...[
                SectionHeader(
                  title: locale.translate('insightHighlights'),
                  action: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.insights),
                    child: Text(locale.translate('viewInsights')),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final insight = insights[index];
                      return SizedBox(
                        width: 240,
                        child: _InsightPreviewCard(
                          insight: insight,
                          locale: locale,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemCount: insights.length,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (coachHighlights.isNotEmpty) ...[
                SectionHeader(
                  title: locale.translate('drivingCoach'),
                  action: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.coach),
                    child: Text(locale.translate('coachPreviewCTA')),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: coachHighlights.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final tip = coachHighlights[index];
                      return SizedBox(
                        width: 220,
                        child: _CoachPreviewCard(tip: tip),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (nextJourney != null) ...[
                SectionHeader(
                  title: locale.translate('journeyNext'),
                  action: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.journeys),
                    child: Text(locale.translate('journeyViewPlanner')),
                  ),
                ),
                const SizedBox(height: 12),
                _NextJourneyCard(
                  plan: nextJourney,
                  appController: appController,
                  locale: locale,
                  onOpenPlanner: () =>
                      Navigator.of(context).pushNamed(AppRoutes.journeys),
                ),
                const SizedBox(height: 24),
              ],
              if (journeyHighlights.isNotEmpty) ...[
                SectionHeader(
                  title: locale.translate('journeyPlanner'),
                  action: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.journeys),
                    child: Text(locale.translate('journeyViewPlanner')),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: journeyHighlights.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final plan = journeyHighlights[index];
                      return SizedBox(
                        width: 240,
                        child: _JourneyPreviewCard(
                          plan: plan,
                          appController: appController,
                          locale: locale,
                          onOpenPlanner: () => Navigator.of(context)
                              .pushNamed(AppRoutes.journeys),
                          onFavorite: () =>
                              journeyController.toggleFavorite(plan.id),
                          onAiInfo: () =>
                              _showJourneyNote(context, plan.aiNote),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SectionHeader(
                title: 'Battery status',
                action: Text('${(vehicle.batteryLevel * 100).round()}%'),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: vehicle.batteryLevel,
                      color: appController.primaryColor,
                      backgroundColor:
                          appController.primaryColor.withOpacity(0.2),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(appController.formatDistance(vehicle.range)),
                        const Spacer(),
                        Text(
                          'Charge ready in 42 min',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Drive stats', action: const AiInfoButton()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Efficiency'),
                          const SizedBox(height: 8),
                          Text('92%',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${appController.formatDistance(132, includeUnit: true)} saved this week'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Climate'),
                          const SizedBox(height: 8),
                          Text(appController.formatTemperature(22),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Cabin preconditioning ready'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (upcomingTrip != null) ...[
                SectionHeader(
                  title: 'Upcoming trip',
                  action: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.tripDetails, arguments: upcomingTrip),
                    child: const Text('Details'),
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(upcomingTrip.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          const AiInfoButton(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${upcomingTrip.city} · ${appController.formatDistance(upcomingTrip.distanceKm)}',
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=900&q=60',
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Start smart navigation',
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRoutes.tripDetails, arguments: upcomingTrip),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SectionHeader(
                title: 'Energy timeline',
                action: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.energy),
                  child: const Text('See all'),
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      7,
                      (index) => Expanded(
                        child: Container(
                          height: 40 + (index * 10),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                appController.primaryColor.withOpacity(.2),
                                appController.primaryColor,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (timeline.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: locale.translate('activityTimeline'),
                  action: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.activity),
                    child: Text(locale.translate('viewAll')),
                  ),
                ),
                const SizedBox(height: 12),
                ...timeline.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActivityPreviewTile(
                      entry: entry,
                      locale: locale,
                      appController: appController,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InsightPreviewCard extends StatelessWidget {
  const _InsightPreviewCard({
    required this.insight,
    required this.locale,
  });

  final Insight insight;
  final AppLocalizations locale;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            insight.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(insight.category.icon,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${(insight.impact * 100).round()}% · ${insight.trend >= 0 ? '+' : ''}${insight.trend}%',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            locale.translate('insightAction'),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          Text(
            insight.action,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CoachPreviewCard extends StatelessWidget {
  const _CoachPreviewCard({required this.tip});

  final DrivingTip tip;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tip.category.icon,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(tip.focus),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                label: Text('+${tip.scoreImpact.toStringAsFixed(1)}'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (tip.badge != null) ...[
            const SizedBox(height: 8),
            Text(
              tip.badge!,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _JourneyPreviewCard extends StatelessWidget {
  const _JourneyPreviewCard({
    required this.plan,
    required this.appController,
    required this.locale,
    required this.onOpenPlanner,
    required this.onFavorite,
    required this.onAiInfo,
  });

  final JourneyPlan plan;
  final AppController appController;
  final AppLocalizations locale;
  final VoidCallback onOpenPlanner;
  final VoidCallback onFavorite;
  final VoidCallback onAiInfo;

  String _formatDeparture(DateTime date) {
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${date.month}/${date.day} · $time';
  }

  String _focusLabel(String focus) {
    switch (focus) {
      case 'express':
        return locale.translate('journeyFocusFast');
      case 'scenic':
        return locale.translate('journeyFocusScenic');
      default:
        return locale.translate('journeyFocusEco');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 2.2,
              child: Image.network(plan.mapImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${plan.origin} → ${plan.destination}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(
                  plan.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: plan.isFavorite
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                ),
                onPressed: onFavorite,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${appController.formatDistance(plan.distanceKm)} · '
              '${plan.durationHours.toStringAsFixed(1)} h'),
          const SizedBox(height: 4),
          Text(
            '${locale.translate('journeyDepartureLabel')}: ${_formatDeparture(plan.departure)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Chip(
                label: Text(_focusLabel(plan.focus)),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              AiInfoButton(onTap: onAiInfo),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: onOpenPlanner,
            child: Text(locale.translate('journeyViewPlanner')),
          ),
        ],
      ),
    );
  }
}

class _NextJourneyCard extends StatelessWidget {
  const _NextJourneyCard({
    required this.plan,
    required this.appController,
    required this.locale,
    required this.onOpenPlanner,
  });

  final JourneyPlan plan;
  final AppController appController;
  final AppLocalizations locale;
  final VoidCallback onOpenPlanner;

  String _formatDeparture(DateTime date) {
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${date.month}/${date.day} · $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${plan.origin} → ${plan.destination}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${appController.formatDistance(plan.distanceKm)} · '
                  '${plan.durationHours.toStringAsFixed(1)} h',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Chip(
                label: Text('${plan.bufferPercent.toStringAsFixed(0)}%'),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${plan.chargeLimit.toStringAsFixed(0)}%'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${locale.translate('journeyDepartureLabel')}: ${_formatDeparture(plan.departure)}',
          ),
          const SizedBox(height: 8),
          Text(
            '${locale.translate('journeyEnergyLabel')}: ${plan.energyCost.toStringAsFixed(0)} kWh',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: plan.stops.take(3).map((stop) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(stop, style: theme.textTheme.bodySmall),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: locale.translate('journeyViewPlanner'),
            onPressed: onOpenPlanner,
          ),
        ],
      ),
    );
  }
}

class _ActivityPreviewTile extends StatelessWidget {
  const _ActivityPreviewTile({
    required this.entry,
    required this.locale,
    required this.appController,
  });

  final ActivityEntry entry;
  final AppLocalizations locale;
  final AppController appController;

  @override
  Widget build(BuildContext context) {
    final color = entry.categoryColor(Theme.of(context).colorScheme);
    final timeFormatter = MaterialLocalizations.of(context);
    final timestamp = timeFormatter.formatTimeOfDay(
      TimeOfDay.fromDateTime(entry.timestamp),
    );
    final metric = _formatMetric();
    return AppCard(
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.activity),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _categoryLabel(entry.category),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric ?? entry.status ?? locale.translate('activityOpen'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _formatMetric() {
    if (entry.metricValue == null) return null;
    final label = entry.metricLabel ?? '';
    if (label.toLowerCase().contains('km')) {
      return appController.formatDistance(entry.metricValue!, includeUnit: true);
    }
    if (label.contains('%')) {
      return '${entry.metricValue!.toStringAsFixed(0)}$label';
    }
    return '${entry.metricValue!.toStringAsFixed(0)} $label'.trim();
  }

  String _categoryLabel(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.charging:
        return locale.translate('activityCharging');
      case ActivityCategory.trip:
        return locale.translate('activityTrips');
      case ActivityCategory.maintenance:
        return locale.translate('activityMaintenance');
      case ActivityCategory.energy:
        return locale.translate('activityEnergy');
      case ActivityCategory.alert:
        return locale.translate('activityAlerts');
    }
  }
}

class _DiagnosticsPreview extends StatelessWidget {
  const _DiagnosticsPreview({
    required this.controller,
    required this.locale,
  });

  final DiagnosticsController controller;
  final AppLocalizations locale;

  @override
  Widget build(BuildContext context) {
    final reports = controller.reports.toList()
      ..sort((a, b) => a.health.compareTo(b.health));
    final focusReports = reports.take(3).toList();
    final overall = (controller.overallHealth * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.translate('overallHealth'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$overall%',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: controller.overallHealth),
              const SizedBox(height: 8),
              Text(
                '${locale.translate('criticalIssues')}: ${controller.criticalCount}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                locale.translate('diagnosticsSubtitle'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final report = focusReports[index];
              final statusKey = report.health > 0.8
                  ? 'diagnosticsStatusGood'
                  : report.health > 0.65
                      ? 'diagnosticsStatusMonitor'
                      : 'diagnosticsStatusAction';
              final delta = (report.delta * 100).toStringAsFixed(1);
              return SizedBox(
                width: 190,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.translate(report.titleKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(locale.translate(statusKey),
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: report.health),
                      const Spacer(),
                      Text(
                        '${(report.health * 100).round()}%',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${report.delta >= 0 ? '+' : ''}$delta% vs last scan',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: focusReports.length,
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicleController,
    required this.appController,
  });

  final VehicleController vehicleController;
  final AppController appController;

  @override
  Widget build(BuildContext context) {
    final vehicle = vehicleController.currentVehicle;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    const SizedBox(height: 4),
                    Text(
                      'Range ${appController.formatDistance(vehicle.range.toDouble())} · top ${vehicle.speed} km/h',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const AiInfoButton(),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: vehicleController.vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = vehicleController.vehicles[index];
                final selected = item.id == vehicle.id;
                return ChoiceChip(
                  label: Text(item.name.split(' ').last),
                  selected: selected,
                  onSelected: (_) => vehicleController.selectVehicle(index),
                );
              },
            ),
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
              _QuickAction(icon: IconlyBold.moon, label: 'Lights'),
              _QuickAction(icon: IconlyBold.volume_up, label: 'Honk'),
              _QuickAction(icon: IconlyBold.setting, label: 'Control'),
            ],
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
