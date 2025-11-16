import 'package:flutter/material.dart';

import '../../core/controllers/activity_controller.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/activity_entry.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/filter_chip_widget.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';

class ActivityCenterScreen extends StatelessWidget {
  const ActivityCenterScreen({
    super.key,
    required this.controller,
    required this.appController,
  });

  final ActivityController controller;
  final AppController appController;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final categories = [
      (null, locale.translate('all')),
      (ActivityCategory.charging, locale.translate('activityCharging')),
      (ActivityCategory.trip, locale.translate('activityTrips')),
      (ActivityCategory.maintenance, locale.translate('activityMaintenance')),
      (ActivityCategory.energy, locale.translate('activityEnergy')),
      (ActivityCategory.alert, locale.translate('activityAlerts')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('activityCenter')),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final entries = controller.filteredEntries;
          final pinned = controller.pinnedEntries;
          return RefreshIndicator(
            onRefresh: controller.refresh,
            displacement: 36,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.translate('activityTimeline'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            locale.translate('activitySubtitle'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    AiInfoButton(
                      onTap: () => _showInfo(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (controller.loading)
                  const LinearProgressIndicator(minHeight: 3),
                if (controller.loading) const SizedBox(height: 16),
                _ActivityStats(entries: entries, controller: controller),
                const SizedBox(height: 24),
                SectionHeader(title: locale.translate('activityFilters')),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final tuple in categories)
                        FilterChipWidget(
                          label: tuple.$2,
                          selected: controller.filter == tuple.$1,
                          onSelected: (_) =>
                              controller.setFilter(tuple.$1),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  title: Text(locale.translate('activityOpenOnly')),
                  value: controller.showOpenOnly,
                  onChanged: controller.toggleShowOpenOnly,
                ),
                if (pinned.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SectionHeader(title: locale.translate('activityPinned')),
                  const SizedBox(height: 8),
                  ...pinned.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ActivityTile(
                        entry: entry,
                        locale: locale,
                        appController: appController,
                        onPin: () => controller.togglePin(entry.id),
                        onResolve: () => controller.toggleResolved(entry.id),
                        onTap: () => _showEntryDetails(context, entry, locale),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SectionHeader(
                  title: locale.translate('activityTimeline'),
                  action: Text('${entries.length} ${locale.translate('results')}'),
                ),
                const SizedBox(height: 12),
                if (entries.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        locale.translate('activityEmpty'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ActivityTile(
                        entry: entry,
                        locale: locale,
                        appController: appController,
                        onPin: () => controller.togglePin(entry.id),
                        onResolve: () => controller.toggleResolved(entry.id),
                        onTap: () => _showEntryDetails(context, entry, locale),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: locale.translate('generateReport'),
                  onPressed: () => _showReportDialog(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Coach',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Soon this center will surface AI-generated insights, risk alerts, and proactive suggestions tailored to your EV lifestyle. For now everything runs locally with mock data.',
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(
    BuildContext context,
    ActivityEntry entry,
    AppLocalizations locale,
  ) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final timeLabel =
        materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(entry.timestamp));
    final dateLabel = materialLocalizations.formatFullDate(entry.timestamp);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('$dateLabel · $timeLabel'),
            const SizedBox(height: 16),
            Text(entry.description),
            const SizedBox(height: 16),
            if (entry.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(locale.translate('close')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: entry.resolved
                        ? locale.translate('reopen')
                        : locale.translate('markResolved'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.toggleResolved(entry.id);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('generateReport')),
        content: const Text(
          'A PDF-style summary will be generated offline in the next milestone. For now we simulate the flow to preview the UX.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).translate('close')),
          ),
        ],
      ),
    );
  }
}

class _ActivityStats extends StatelessWidget {
  const _ActivityStats({
    required this.entries,
    required this.controller,
  });

  final List<ActivityEntry> entries;
  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    final open = entries.where((entry) => !entry.resolved).length;
    final resolved = entries.where((entry) => entry.resolved).length;
    final pinned = controller.pinnedEntries.length;
    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: _StatTile(
              label: AppLocalizations.of(context).translate('activityOpen'),
              value: open.toString(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            child: _StatTile(
              label: AppLocalizations.of(context).translate('activityResolvedLabel'),
              value: resolved.toString(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            child: _StatTile(
              label: AppLocalizations.of(context).translate('activityPinned'),
              value: pinned.toString(),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.entry,
    required this.locale,
    required this.appController,
    required this.onPin,
    required this.onResolve,
    required this.onTap,
  });

  final ActivityEntry entry;
  final AppLocalizations locale;
  final AppController appController;
  final VoidCallback onPin;
  final VoidCallback onResolve;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = entry.categoryColor(Theme.of(context).colorScheme);
    final timeFormatter = MaterialLocalizations.of(context);
    final timestamp =
        '${timeFormatter.formatShortDate(entry.timestamp)} · ${timeFormatter.formatTimeOfDay(TimeOfDay.fromDateTime(entry.timestamp))}';
    final metric = _formatMetric();
    return AppCard(
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 80,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _categoryLabel(entry.category),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: color),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          entry.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                        ),
                        onPressed: onPin,
                      ),
                    ],
                  ),
                  Text(
                    entry.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(entry.description),
                  const SizedBox(height: 8),
                  if (metric != null)
                    Text(
                      metric,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  if (entry.progress != null) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: entry.progress),
                  ],
                  if (entry.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          entry.tags.map((tag) => Chip(label: Text(tag))).toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.status ??
                              (entry.resolved
                                  ? locale.translate('activityResolvedLabel')
                                  : locale.translate('activityOpen')),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        timestamp,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      IconButton(
                        icon: Icon(
                          entry.resolved
                              ? Icons.restart_alt
                              : Icons.check_circle_outline,
                        ),
                        onPressed: onResolve,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String? _formatMetric() {
    final value = entry.metricValue;
    if (value == null) return null;
    final label = entry.metricLabel ?? '';
    if (label.toLowerCase().contains('km')) {
      return appController.formatDistance(value, includeUnit: true);
    }
    if (label.contains('%')) {
      return '${value.toStringAsFixed(0)}${label.replaceAll(' ', '')}';
    }
    return '${value.toStringAsFixed(0)} $label'.trim();
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
