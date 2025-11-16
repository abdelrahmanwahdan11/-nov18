import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/maintenance_task.dart';
import '../../core/widgets/app_card.dart';
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
                    child: ListView.builder(
                      key: ValueKey(index),
                      padding: const EdgeInsets.all(24),
                      itemCount: tasks.length,
                      itemBuilder: (context, i) {
                        final task = tasks[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                const SizedBox(height: 8),
                                Text('Current mileage ${task.currentMileage} km'),
                                Text('Next service ${task.nextServiceMileage} km'),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(value: task.progress),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
