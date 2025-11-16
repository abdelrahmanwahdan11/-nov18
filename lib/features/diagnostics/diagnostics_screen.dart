import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/diagnostics_controller.dart';
import '../../core/controllers/vehicle_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/diagnostic_report.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/filter_chip_widget.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';

class VehicleDiagnosticsScreen extends StatefulWidget {
  const VehicleDiagnosticsScreen({
    super.key,
    required this.controller,
    required this.vehicleController,
  });

  final DiagnosticsController controller;
  final VehicleController vehicleController;

  @override
  State<VehicleDiagnosticsScreen> createState() =>
      _VehicleDiagnosticsScreenState();
}

class _VehicleDiagnosticsScreenState extends State<VehicleDiagnosticsScreen> {
  bool predictiveAlerts = true;
  bool autoSchedule = true;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final categories = [
      (null, locale.translate('diagnosticsFilterAll')),
      (DiagnosticCategory.battery, locale.translate('diagnosticsBattery')),
      (DiagnosticCategory.charging, locale.translate('diagnosticsCharging')),
      (DiagnosticCategory.tires, locale.translate('diagnosticsTires')),
      (DiagnosticCategory.climate, locale.translate('diagnosticsClimate')),
      (DiagnosticCategory.software, locale.translate('diagnosticsSoftware')),
      (DiagnosticCategory.brakes, locale.translate('diagnosticsBrakes')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('diagnostics')),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showAiSheet(context, locale),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.controller.refresh,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          widget.controller,
          widget.vehicleController,
        ]),
        builder: (context, _) {
          final vehicle = widget.vehicleController.currentVehicle;
          final reports = widget.controller.filteredReports;
          final timeline = widget.controller.filteredTimeline;
          final recommendations = widget.controller.recommendations;
          return RefreshIndicator(
            onRefresh: widget.controller.refresh,
            displacement: 32,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                _DiagnosticsHero(
                  controller: widget.controller,
                  vehicleName: vehicle.name,
                  predictiveAlerts: predictiveAlerts,
                  autoSchedule: autoSchedule,
                  onTogglePredictive: (value) =>
                      setState(() => predictiveAlerts = value),
                  onToggleAutoSchedule: (value) =>
                      setState(() => autoSchedule = value),
                  locale: locale,
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: locale.translate('systemsHealth'),
                  action: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.home),
                    child: Text(locale.translate('dashboard')),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final tuple in categories)
                        FilterChipWidget(
                          label: tuple.$2,
                          selected: widget.controller.filter == tuple.$1,
                          onSelected: (_) =>
                              widget.controller.setFilter(tuple.$1),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.controller.loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                if (reports.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.translate('diagnosticsNoReports'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(locale.translate('diagnosticsSubtitle')),
                        ],
                      ),
                    ),
                  )
                else
                  ...reports.map(
                    (report) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DiagnosticReportTile(
                        report: report,
                        locale: locale,
                        onNavigate: () =>
                            Navigator.of(context).pushReplacementNamed(
                          AppRoutes.home,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SectionHeader(title: locale.translate('diagnosticsTimeline')),
                const SizedBox(height: 12),
                if (timeline.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(locale.translate('diagnosticsNoTimeline')),
                    ),
                  )
                else
                  ...timeline.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TimelineTile(
                        entry: entry,
                        locale: locale,
                        onToggle: () => widget.controller.toggleResolved(entry.id),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: locale.translate('diagnosticsRecommendations'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final key in recommendations)
                      Chip(label: Text(locale.translate(key))),
                  ],
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: locale.translate('runScan'),
                  onPressed: widget.controller.refresh,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAiSheet(BuildContext context, AppLocalizations locale) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.translate('diagnostics'),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(locale.translate('diagnosticsAiExplainer')),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(locale.translate('close')),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _DiagnosticsHero extends StatelessWidget {
  const _DiagnosticsHero({
    required this.controller,
    required this.vehicleName,
    required this.predictiveAlerts,
    required this.autoSchedule,
    required this.onTogglePredictive,
    required this.onToggleAutoSchedule,
    required this.locale,
  });

  final DiagnosticsController controller;
  final String vehicleName;
  final bool predictiveAlerts;
  final bool autoSchedule;
  final ValueChanged<bool> onTogglePredictive;
  final ValueChanged<bool> onToggleAutoSchedule;
  final AppLocalizations locale;

  @override
  Widget build(BuildContext context) {
    final health = controller.overallHealth;
    final percentage = (health * 100).round();
    final lastScan = controller.lastScan;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.translate('vehicleHealth'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('${locale.translate('overallHealth')}: $percentage%'),
                    if (lastScan != null)
                      Text(
                        '${locale.translate('lastScan')}: '
                        '${TimeOfDay.fromDateTime(lastScan).format(context)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const AiInfoButton(),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: health),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(locale.translate('criticalIssues')),
                    Text(
                      controller.criticalCount.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(locale.translate('garage')),
                    Text(
                      vehicleName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: predictiveAlerts,
            title: Text(locale.translate('diagnosticsPredictiveAlerts')),
            onChanged: onTogglePredictive,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: autoSchedule,
            title: Text(locale.translate('diagnosticsAutoSchedule')),
            onChanged: onToggleAutoSchedule,
          ),
        ],
      ),
    );
  }
}

class _DiagnosticReportTile extends StatelessWidget {
  const _DiagnosticReportTile({
    required this.report,
    required this.locale,
    required this.onNavigate,
  });

  final DiagnosticReport report;
  final AppLocalizations locale;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final statusKey = report.health > 0.8
        ? 'diagnosticsStatusGood'
        : report.health > 0.65
            ? 'diagnosticsStatusMonitor'
            : 'diagnosticsStatusAction';
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      Text(
                        locale.translate(report.titleKey),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(locale.translate(report.summaryKey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(report.health * 100).round()}%'),
                    Text(locale.translate(statusKey),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: report.health),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final metric in report.metrics)
                  _MetricBadge(metric: metric, locale: locale),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in report.recommendationKeys)
                  Chip(label: Text(locale.translate(key))),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onNavigate,
                child: Text(locale.translate('viewDiagnostics')),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.metric, required this.locale});

  final DiagnosticMetric metric;
  final AppLocalizations locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.translate(metric.labelKey),
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        Text(
          metric.valueLabel,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (metric.trendLabel != null)
          Text(
            metric.trendLabel!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.locale,
    required this.onToggle,
  });

  final DiagnosticTimelineEntry entry;
  final AppLocalizations locale;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForCategory(entry.category);
    return AppCard(
      child: ListTile(
        leading: Icon(icon),
        title: Text(locale.translate(entry.titleKey)),
        subtitle: Text(locale.translate(entry.detailKey)),
        trailing: IconButton(
          icon: Icon(entry.resolved ? Icons.check_circle : Icons.timelapse),
          onPressed: onToggle,
        ),
      ),
    );
  }

  IconData _iconForCategory(DiagnosticCategory category) {
    switch (category) {
      case DiagnosticCategory.battery:
        return Icons.bolt;
      case DiagnosticCategory.charging:
        return Icons.ev_station;
      case DiagnosticCategory.tires:
        return Icons.tire_repair;
      case DiagnosticCategory.software:
        return Icons.memory_rounded;
      case DiagnosticCategory.climate:
        return Icons.ac_unit;
      case DiagnosticCategory.brakes:
        return Icons.speed;
    }
  }
}
