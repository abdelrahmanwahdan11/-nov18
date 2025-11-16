import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/controllers/journey_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/journey_plan.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';

class JourneyPlannerScreen extends StatefulWidget {
  const JourneyPlannerScreen({
    super.key,
    required this.controller,
    required this.appController,
  });

  final JourneyController controller;
  final AppController appController;

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen> {
  final TextEditingController _originController =
      TextEditingController(text: 'Riyadh HQ');
  final TextEditingController _destinationController =
      TextEditingController(text: 'AlUla Canyon');
  double _buffer = 15;
  double _chargeLimit = 80;
  bool _autoBalance = true;
  String _focus = 'eco';

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _showAiSheet(AppLocalizations locale) {
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
                locale.translate('journeyPlanner'),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(locale.translate('journeyAiInfo')),
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
        );
      },
    );
  }

  void _generatePlan(AppLocalizations locale) {
    widget.controller.scheduleCustomPlan(
      origin: _originController.text,
      destination: _destinationController.text,
      bufferPercent: _buffer,
      chargeLimit: _chargeLimit,
      focus: _focus,
      autoAdjustClimate: _autoBalance,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(locale.translate('journeyPlanAdded'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final focusOptions = [
      ('eco', locale.translate('journeyFocusEco'), Icons.eco_rounded),
      ('express', locale.translate('journeyFocusFast'), Icons.bolt),
      ('scenic', locale.translate('journeyFocusScenic'), Icons.landscape),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('journeyPlanner')),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showAiSheet(locale),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final plans = widget.controller.plans;
          final nextJourney = widget.controller.nextJourney;
          return RefreshIndicator(
            onRefresh: widget.controller.refreshPlans,
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(
                  locale.translate('journeyPlannerSubtitle'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _originController,
                        decoration: InputDecoration(
                          labelText: locale.translate('journeyFormOrigin'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          labelText: locale.translate('journeyFormDestination'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${locale.translate('journeyBufferLabel')} ${_buffer.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Slider(
                        value: _buffer,
                        min: 5,
                        max: 25,
                        divisions: 4,
                        onChanged: (value) => setState(() => _buffer = value),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${locale.translate('journeyChargeLabel')} ${_chargeLimit.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Slider(
                        value: _chargeLimit,
                        min: 60,
                        max: 100,
                        divisions: 8,
                        onChanged: (value) => setState(() => _chargeLimit = value),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(locale.translate('journeyAutoBalance')),
                        value: _autoBalance,
                        onChanged: (value) => setState(() => _autoBalance = value),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locale.translate('journeyFocusLabel'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: focusOptions
                            .map(
                              (option) => ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(option.$3, size: 16),
                                    const SizedBox(width: 6),
                                    Text(option.$2),
                                  ],
                                ),
                                selected: _focus == option.$1,
                                onSelected: (_) =>
                                    setState(() => _focus = option.$1),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: locale.translate('journeyGenerate'),
                        onPressed: () => _generatePlan(locale),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (nextJourney != null) ...[
                  SectionHeader(
                    title: locale.translate('journeyNext'),
                    action: TextButton(
                      onPressed: widget.controller.refreshPlans,
                      child: Text(locale.translate('journeyRefresh')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _JourneyPlanCard(
                    plan: nextJourney,
                    locale: locale,
                    appController: widget.appController,
                    onFavorite: () =>
                        widget.controller.toggleFavorite(nextJourney.id),
                    onAiInfo: () => _showPlanAi(context, nextJourney.aiNote),
                  ),
                  const SizedBox(height: 24),
                ],
                SectionHeader(
                  title: locale.translate('journeyUpcoming'),
                  action: TextButton(
                    onPressed: widget.controller.refreshPlans,
                    child: Text(locale.translate('journeyRefresh')),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return _JourneyPlanCard(
                      plan: plan,
                      locale: locale,
                      appController: widget.appController,
                      onFavorite: () =>
                          widget.controller.toggleFavorite(plan.id),
                      onAiInfo: () => _showPlanAi(context, plan.aiNote),
                    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1);
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPlanAi(BuildContext context, String note) {
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

class _JourneyPlanCard extends StatelessWidget {
  const _JourneyPlanCard({
    required this.plan,
    required this.locale,
    required this.appController,
    required this.onFavorite,
    required this.onAiInfo,
  });

  final JourneyPlan plan;
  final AppLocalizations locale;
  final AppController appController;
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
            child: Image.network(
              plan.mapImage,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${plan.origin} → ${plan.destination}',
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
          Text('${appController.formatDistance(plan.distanceKm)} • '
              '${plan.durationHours.toStringAsFixed(1)} h'),
          const SizedBox(height: 8),
          Text(
            locale.translate('journeyStopsLabel'),
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: plan.stops
                .map(
                  (stop) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(stop, style: theme.textTheme.bodySmall),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${locale.translate('journeyDepartureLabel')}: ${_formatDeparture(plan.departure)}',
              ),
              Chip(
                label: Text(_focusLabel(plan.focus)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${locale.translate('journeyEnergyLabel')}: ${plan.energyCost.toStringAsFixed(0)} kWh',
          ),
          const SizedBox(height: 4),
          Text(
            '${locale.translate('journeyWeatherLabel')}: ${plan.weather}',
          ),
          const SizedBox(height: 4),
          Text(
            '${locale.translate('journeyBufferLabel')}: ${plan.bufferPercent.toStringAsFixed(0)}% • '
            '${locale.translate('journeyChargeLabel')} ${plan.chargeLimit.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${locale.translate('journeyDurationLabel')}: ${plan.durationHours.toStringAsFixed(1)} h',
                  style: theme.textTheme.labelMedium,
                ),
              ),
              AiInfoButton(onTap: onAiInfo),
            ],
          ),
        ],
      ),
    );
  }
}
