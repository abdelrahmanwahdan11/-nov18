import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/controllers/insights_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/insight.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_header.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({
    super.key,
    required this.controller,
    required this.appController,
  });

  final InsightsController controller;
  final AppController appController;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightCategory? filter;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final categoryLabels = {
      InsightCategory.efficiency: locale.translate('insightCategoryEfficiency'),
      InsightCategory.charging: locale.translate('insightCategoryCharging'),
      InsightCategory.trips: locale.translate('insightCategoryTrips'),
      InsightCategory.maintenance:
          locale.translate('insightCategoryMaintenance'),
      InsightCategory.driving: locale.translate('insightCategoryDriving'),
    };
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final insights = widget.controller.insights
            .where((insight) => filter == null || insight.category == filter)
            .toList();
        final pinned = widget.controller.pinned;
        final trendEntries = widget.controller.weeklyEfficiency.entries.toList();
        final mix = widget.controller.energyMix;
        return Scaffold(
          appBar: AppBar(
            title: Text(locale.translate('insights')),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: widget.controller.loading
                    ? null
                    : () => widget.controller.refresh(),
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded),
                onPressed: widget.controller.loading
                    ? null
                    : widget.controller.resetDemo,
              )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: widget.controller.refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  locale.translate('insightsSubtitle'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: locale.translate('insightHighlights'),
                  action: const AiInfoButton(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final insight = widget.controller.highlights[index];
                      return SizedBox(
                        width: 240,
                        child: _InsightCard(
                          insight: insight,
                          categoryLabel: categoryLabels[insight.category]!,
                          onTogglePin: () =>
                              widget.controller.togglePin(insight.id),
                          onAcknowledge: () =>
                              widget.controller.acknowledge(insight.id),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemCount: widget.controller.highlights.length,
                  ),
                ),
                const SizedBox(height: 24),
                if (pinned.isNotEmpty) ...[
                  SectionHeader(title: locale.translate('insightPinned')),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: pinned
                        .map(
                          (insight) => SizedBox(
                            width: 220,
                            child: _InsightChip(
                              insight: insight,
                              categoryLabel: categoryLabels[insight.category]!,
                              onPressed: () =>
                                  widget.controller.togglePin(insight.id),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                SectionHeader(title: locale.translate('insightCoaching')),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(locale.translate('all')),
                      selected: filter == null,
                      onSelected: (_) => setState(() => filter = null),
                    ),
                    ...InsightCategory.values.map(
                      (category) => ChoiceChip(
                        label: Text(categoryLabels[category] ?? category.name),
                        selected: filter == category,
                        onSelected: (_) => setState(() => filter = category),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.controller.loading)
                  const Center(child: CircularProgressIndicator()),
                if (insights.isEmpty && !widget.controller.loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      locale.translate('insightEmpty'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ...insights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InsightCard(
                      insight: insight,
                      categoryLabel: categoryLabels[insight.category]!,
                      onTogglePin: () =>
                          widget.controller.togglePin(insight.id),
                      onAcknowledge: () =>
                          widget.controller.acknowledge(insight.id),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SectionHeader(title: locale.translate('insightTrends')),
                const SizedBox(height: 12),
                AppCard(
                  child: SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: trendEntries
                          .map(
                            (entry) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: entry.value,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gradient: LinearGradient(
                                              colors: [
                                                widget.appController.primaryColor
                                                    .withOpacity(.2),
                                                widget.appController.primaryColor,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(entry.key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: locale.translate('insightEnergyMix')),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...mix.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key.toUpperCase()),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: entry.value / 100,
                                minHeight: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        locale.translate('insightRefreshHint'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.energy),
                        icon: const Icon(Icons.bolt_rounded),
                        label: Text(locale.translate('energy')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.insight,
    required this.categoryLabel,
    required this.onTogglePin,
    required this.onAcknowledge,
  });

  final Insight insight;
  final String categoryLabel;
  final VoidCallback onTogglePin;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(.1),
                child: Icon(insight.category.icon,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(insight.description),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  insight.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                onPressed: onTogglePin,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(categoryLabel),
              const Spacer(),
              Text('${(insight.impact * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: insight.impact),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.translate('insightAction'),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(insight.action),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onAcknowledge,
                child: Text(insight.acknowledged
                    ? locale.translate('markResolved')
                    : locale.translate('insightAcknowledge')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({
    required this.insight,
    required this.categoryLabel,
    required this.onPressed,
  });

  final Insight insight;
  final String categoryLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(categoryLabel.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          Text(
            insight.title,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(insight.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onPressed,
            child: Text(AppLocalizations.of(context).translate('remove')),
          ),
        ],
      ),
    );
  }
}
