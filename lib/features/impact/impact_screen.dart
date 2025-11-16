import 'package:flutter/material.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/controllers/impact_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/impact_report.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({
    super.key,
    required this.controller,
    required this.appController,
  });

  final ImpactController controller;
  final AppController appController;

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final summary = widget.controller.summary;
        final mix = widget.controller.energyMix.entries.toList();
        final achievements = widget.controller.achievements;
        final actions = widget.controller.actions;
        final reports = widget.controller.reports;
        final goalLabel = locale.translate('impactGoalLabel')
            .replaceAll('{value}', widget.controller.goal.round().toString());
        return Scaffold(
          appBar: AppBar(
            title: Text(locale.translate('impactTitle')),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download_done_outlined),
                onPressed: widget.controller.loading
                    ? null
                    : () {
                        final exported = widget.controller.exportDigest();
                        final label = locale
                            .translate('impactExportToast')
                            .replaceAll('{value}', _formatTimestamp(exported));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(label)),
                        );
                      },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed:
                    widget.controller.loading ? null : widget.controller.refresh,
              )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: widget.controller.refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(
                  locale.translate('impactSubtitle'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.translate('impactHeroSaved'),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.carbonSavedKg.toStringAsFixed(1)} kg',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          _HeroStat(
                            label: locale.translate('impactHeroTrees'),
                            value:
                                summary.treeEquivalent.toStringAsFixed(0),
                          ),
                          _HeroStat(
                            label: locale.translate('impactHeroRegen'),
                            value:
                                '${summary.energyRegainedKwh.toStringAsFixed(0)} kWh',
                          ),
                          _HeroStat(
                            label: locale.translate('impactHeroTrips'),
                            value: summary.smartTrips.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (summary.highlights.isNotEmpty)
                        Text(summary.highlights.first),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: locale.translate('impactGoalTitle'),
                  action: Text(goalLabel),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.translate('impactGoalHelper')),
                      Slider(
                        value: widget.controller.goal,
                        min: 50,
                        max: 100,
                        divisions: 10,
                        label: widget.controller.goal.round().toString(),
                        onChanged: widget.controller.updateGoal,
                        activeColor: widget.appController.primaryColor,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(locale.translate('impactGoalMin')),
                          Text(locale.translate('impactGoalMax')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: locale.translate('impactTrendTitle'),
                  action: const AiInfoButton(),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: SizedBox(
                    height: 170,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: widget.controller.weeklyTrend
                          .map(
                            (point) => Expanded(
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
                                          height: point.value,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                              colors: [
                                                widget.appController
                                                    .primaryColor
                                                    .withOpacity(.15),
                                                widget.appController
                                                    .primaryColor,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(point.label),
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
                SectionHeader(
                  title: locale.translate('impactMixTitle'),
                  action: Text(locale
                      .translate('impactMixShare')
                      .replaceAll('{value}',
                          '${(summary.renewableShare * 100).round()}%')),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: mix
                      .map(
                        (entry) => SizedBox(
                          width: 150,
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.key.toUpperCase()),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: entry.value,
                                  minHeight: 6,
                                  color: widget.appController.primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text('${(entry.value * 100).round()}%'),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: locale.translate('impactAchievementsTitle'),
                ),
                const SizedBox(height: 12),
                ...achievements.map(
                  (achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  achievement.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Icon(
                                achievement.unlocked
                                    ? Icons.verified
                                    : Icons.lock_outline,
                                color: achievement.unlocked
                                    ? widget.appController.primaryColor
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(achievement.description),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: achievement.progress,
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: locale.translate('impactActionsTitle'),
                ),
                const SizedBox(height: 12),
                ...actions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(action.title),
                        subtitle: Text(action.subtitle),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                action.bookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                              ),
                              onPressed: () => widget.controller
                                  .toggleActionBookmark(action.id),
                            ),
                            Text('${(action.potential * 100).round()}%'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: locale.translate('impactReportsTitle'),
                ),
                const SizedBox(height: 12),
                ...reports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.period,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(report.summary),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  locale.translate('impactReportUsage').replaceAll(
                                        '{value}',
                                        report.energyUsed.toStringAsFixed(0),
                                      ),
                                ),
                              ),
                              Text(
                                '${(report.energyFromRenewables * 100).round()}% ${locale.translate('impactReportRenewables')}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(report.recommendation),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            label: locale.translate('impactReportButton'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(locale
                                      .translate('impactReportToast')
                                      .replaceAll('{period}', report.period)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.controller.lastExport != null)
                  Text(
                    locale.translate('impactExportHint').replaceAll(
                        '{value}',
                        _formatTimestamp(widget.controller.lastExport!)),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    final date =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
