import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/controllers/coach_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/driving_tip.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/filter_chip_widget.dart';
import '../../core/widgets/section_header.dart';

class DrivingCoachScreen extends StatefulWidget {
  const DrivingCoachScreen({super.key, required this.controller});

  final CoachController controller;

  @override
  State<DrivingCoachScreen> createState() => _DrivingCoachScreenState();
}

class _DrivingCoachScreenState extends State<DrivingCoachScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final highlights = widget.controller.highlightTips();
        final tips = widget.controller.tips;
        final score = widget.controller.ecoScore;
        final focus = widget.controller.focusBreakdown;
        return Scaffold(
          appBar: AppBar(
            title: Text(locale.translate('drivingCoach')),
            actions: [
              AiInfoButton(onPressed: () => _showAiSheet(context, locale)),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: widget.controller.refreshRecommendations,
            child: ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(24),
              children: [
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
                                Text(
                                  locale.translate('coachEcoScore'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  locale.translate('coachHeroDescription'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: CircularProgressIndicator(
                                    value: score / 100,
                                    strokeWidth: 10,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      score.toStringAsFixed(0),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '/ 100',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        locale.translate('coachWeeklyProgress'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _FocusPill(
                            label: locale.translate('coachFocusCity'),
                            value: focus['city'] ?? 0,
                          ),
                          _FocusPill(
                            label: locale.translate('coachFocusHighway'),
                            value: focus['highway'] ?? 0,
                          ),
                          _FocusPill(
                            label: locale.translate('coachFocusClimate'),
                            value: focus['climate'] ?? 0,
                          ),
                          _FocusPill(
                            label: locale.translate('coachFocusCharging'),
                            value: focus['charging'] ?? 0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: widget.controller.refreshRecommendations,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(locale.translate('coachRefresh')),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (highlights.isNotEmpty) ...[
                  SectionHeader(
                    title: locale.translate('coachHighlightsTitle'),
                    action: Text(locale.translate('drivingCoachSubtitle')),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: highlights.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final tip = highlights[index];
                        return SizedBox(
                          width: 240,
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      tip.category.icon,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tip.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  tip.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Text(
                                  '${tip.scoreImpact.toStringAsFixed(1)} pts',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms).moveY(begin: 12),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                SectionHeader(title: locale.translate('activityFilters')),
                const SizedBox(height: 12),
                Wrap(
                  children: [
                    FilterChipWidget(
                      label: locale.translate('all'),
                      selected: widget.controller.category == null,
                      onSelected: (_) => widget.controller.selectCategory(null),
                    ),
                    ...CoachCategory.values.map(
                      (category) => FilterChipWidget(
                        label: locale.translate(
                            'coachFilters${_capitalize(category.id)}'),
                        selected: widget.controller.category == category,
                        onSelected: (_) => widget.controller.selectCategory(
                          widget.controller.category == category
                              ? null
                              : category,
                        ),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  value: widget.controller.bookmarkedOnly,
                  onChanged: (_) => widget.controller.toggleBookmarkedOnly(),
                  title: Text(locale.translate('coachBookmarkedOnly')),
                ),
                const SizedBox(height: 16),
                if (tips.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        locale.translate('coachEmpty'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...tips.map(
                    (tip) => _TipCard(
                      tip: tip,
                      locale: locale,
                      onBookmark: () => widget.controller.toggleBookmark(tip.id),
                      onToggle: () => widget.controller.toggleCompleted(tip.id),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAiSheet(BuildContext context, AppLocalizations locale) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 48),
            const SizedBox(height: 16),
            Text(
              locale.translate('coachAiSheetTitle'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              locale.translate('coachAiSheetDescription'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusPill extends StatelessWidget {
  const _FocusPill({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.primary.withOpacity(.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.locale,
    required this.onBookmark,
    required this.onToggle,
  });

  final DrivingTip tip;
  final AppLocalizations locale;
  final VoidCallback onBookmark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(.12),
                  child: Icon(
                    tip.category.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    tip.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  onPressed: onBookmark,
                )
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: locale.translate('coachDuration'),
                  value: tip.duration,
                ),
                _InfoChip(
                  label: locale.translate('coachFocusLabel'),
                  value: tip.focus,
                ),
                _InfoChip(
                  label: locale.translate('coachEcoScore'),
                  value: '+${tip.scoreImpact.toStringAsFixed(1)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    tip.completed
                        ? Icons.undo_rounded
                        : Icons.check_circle_rounded,
                  ),
                  label: Text(
                    tip.completed
                        ? locale.translate('coachMarkUndo')
                        : locale.translate('coachMarkDone'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onBookmark,
                  child: Text(locale.translate('coachBookmark')),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
