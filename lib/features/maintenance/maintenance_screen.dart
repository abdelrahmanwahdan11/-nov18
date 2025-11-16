import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/maintenance_task.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/skeleton_list.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  final tabs = ['All Types', 'Engine Oil Change', 'Tire Rotation', 'Other'];
  int index = 0;
  bool loading = true;
  late final List<MaintenanceTask> tasks;
  final Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    tasks = List.generate(
      4,
      (i) => MaintenanceTask(
        id: '$i',
        title: tabs[i],
        currentMileage: 12000 + i * 2000,
        nextServiceMileage: 20000,
        intervalDays: 180,
        dueDate: DateTime.now().add(Duration(days: 15 * (i + 1))),
        notes: i.isEven
            ? 'Check cabin filter and coolant levels during the visit.'
            : 'Rotate tires diagonally to balance wear.',
        serviceCenter: i.isEven ? 'BMW Downtown' : 'Future Mobility Lab',
        requiresWorkshop: i % 3 == 0,
        healthScore: 70 + i * 6,
      ),
    );
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (mounted) setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: loading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: SkeletonList(),
            )
          : Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, i) => ChoiceChip(
                      label: Text(tabs[i]),
                      selected: index == i,
                      onSelected: (_) => setState(() => index = i),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: tabs.length,
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: 400.ms,
                    child: RefreshIndicator(
                      key: ValueKey(index),
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          _DueSoonBanner(tasks: tasks),
                          const SizedBox(height: 16),
                          ..._filteredTasks.map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _TaskCard(
                                task: task,
                                completed: _completed.contains(task.id),
                                onToggle: () {
                                  setState(() {
                                    if (_completed.contains(task.id)) {
                                      _completed.remove(task.id);
                                    } else {
                                      _completed.add(task.id);
                                    }
                                  });
                                },
                                onAiTap: () => _openAiCoach(task),
                              ),
                            ),
                          ),
                          if (_filteredTasks.isEmpty)
                            AppCard(
                              child: Column(
                                children: const [
                                  SizedBox(height: 12),
                                  Icon(Icons.celebration, size: 36),
                                  SizedBox(height: 8),
                                  Text('All clear · no maintenance required right now'),
                                  SizedBox(height: 12),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logVisit,
        label: const Text('Log service'),
        icon: const Icon(Icons.build_outlined),
      ),
    );
  }

  Iterable<MaintenanceTask> get _filteredTasks => index == 0
      ? tasks
      : tasks.where((task) => task.title == tabs[index]);

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      tasks.shuffle();
    });
  }

  void _openAiCoach(MaintenanceTask task) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI care coach',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Next best action for ${task.title}'),
            const SizedBox(height: 12),
            Text(task.notes ??
                'Detailed insights will appear here when predictive maintenance launches.'),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Got it',
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _logVisit() async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Log maintenance visit',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration:
                  const InputDecoration(labelText: 'Notes (kept locally)'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Save locally',
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Visit saved offline with memo: ${controller.text.isEmpty ? 'No memo' : controller.text}'),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.completed,
    required this.onToggle,
    required this.onAiTap,
  });

  final MaintenanceTask task;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onAiTap;

  @override
  Widget build(BuildContext context) {
    final color = task.isDueSoon
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(task.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              AiInfoButton(onPressed: onAiTap),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.dueLabel,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Current mileage ${task.currentMileage} km'),
          Text('Next service ${task.nextServiceMileage} km'),
          if (task.serviceCenter != null) ...[
            const SizedBox(height: 4),
            Text('Preferred center · ${task.serviceCenter}')
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: task.progress.clamp(0, 1),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.health_and_safety, size: 18),
                label: Text('Health ${task.healthScore}%'),
              ),
              Chip(
                avatar: const Icon(Icons.calendar_today, size: 18),
                label: Text(task.intervalDays == 0
                    ? 'Flexible'
                    : '${task.intervalDays ~/ 30} mo interval'),
              ),
              if (task.requiresWorkshop)
                Chip(
                  avatar: const Icon(Icons.factory_outlined, size: 18),
                  label: const Text('Workshop visit'),
                ),
            ],
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: completed,
            onChanged: (_) => onToggle(),
            title: const Text('Mark task complete (stored locally)'),
          )
        ],
      ),
    );
  }
}

class _DueSoonBanner extends StatelessWidget {
  const _DueSoonBanner({required this.tasks});

  final List<MaintenanceTask> tasks;

  @override
  Widget build(BuildContext context) {
    final dueSoon = tasks.where((task) => task.isDueSoon).length;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: dueSoon > 0
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dueSoon > 0
                      ? '$dueSoon service tasks due soon'
                      : 'All maintenance tasks are up to date',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text('Insights sync locally until cloud backup arrives.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
