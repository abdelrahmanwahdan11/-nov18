import 'dart:math';

import 'package:flutter/material.dart';

import '../models/activity_entry.dart';

class ActivityController extends ChangeNotifier {
  ActivityController() {
    _entries = _seedEntries();
  }

  late List<ActivityEntry> _entries;
  ActivityCategory? _filter;
  bool _showOpenOnly = false;
  bool _loading = false;

  bool get loading => _loading;
  ActivityCategory? get filter => _filter;
  bool get showOpenOnly => _showOpenOnly;

  List<ActivityEntry> get entries => List.unmodifiable(_entries);
  List<ActivityEntry> get pinnedEntries =>
      List.unmodifiable(_entries.where((entry) => entry.pinned));

  List<ActivityEntry> get filteredEntries {
    Iterable<ActivityEntry> list = _entries;
    if (_filter != null) {
      list = list.where((entry) => entry.category == _filter);
    }
    if (_showOpenOnly) {
      list = list.where((entry) => !entry.resolved);
    }
    return list.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<ActivityEntry> recentEntries([int take = 3]) {
    final sorted = List<ActivityEntry>.from(_entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(take).toList();
  }

  void setFilter(ActivityCategory? category) {
    if (_filter == category) return;
    _filter = category;
    notifyListeners();
  }

  void toggleShowOpenOnly(bool value) {
    if (_showOpenOnly == value) return;
    _showOpenOnly = value;
    notifyListeners();
  }

  void togglePin(String id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) return;
    final entry = _entries[index];
    _entries[index] = entry.copyWith(pinned: !entry.pinned);
    notifyListeners();
  }

  void toggleResolved(String id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) return;
    final entry = _entries[index];
    _entries[index] = entry.copyWith(resolved: !entry.resolved);
    notifyListeners();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 700));
    _entries.shuffle(Random());
    _loading = false;
    notifyListeners();
  }

  void addEntry(ActivityEntry entry) {
    _entries = [entry, ..._entries];
    notifyListeners();
  }

  List<ActivityEntry> _seedEntries() {
    final now = DateTime.now();
    return [
      ActivityEntry(
        id: 'activity-charging-1',
        category: ActivityCategory.charging,
        timestamp: now.subtract(const Duration(minutes: 40)),
        title: 'Charging limit reached',
        description: 'i4 M50 stopped at 80% limit and saved 5.2 kWh.',
        status: 'Completed',
        progress: 1,
        tags: const ['Garage', 'AC'],
        metricValue: 80,
        metricLabel: '%',
      ),
      ActivityEntry(
        id: 'activity-trip-1',
        category: ActivityCategory.trip,
        timestamp: now.subtract(const Duration(hours: 3)),
        title: 'Coastal Sprint navigation ready',
        description: 'Route recalculated with two Ionity hubs and light traffic.',
        status: 'Planned',
        tags: const ['Navigation'],
        metricValue: 320,
        metricLabel: 'km',
      ),
      ActivityEntry(
        id: 'activity-maintenance-1',
        category: ActivityCategory.maintenance,
        timestamp: now.subtract(const Duration(hours: 6)),
        title: 'Tire rotation due soon',
        description: 'Front tires will reach 3mm in 700 km. Schedule visit.',
        status: 'Due in 10 days',
        progress: 0.65,
        tags: const ['Garage', 'Care plan'],
        pinned: true,
      ),
      ActivityEntry(
        id: 'activity-energy-1',
        category: ActivityCategory.energy,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        title: 'Energy mix update',
        description: 'Solar roof provided 18% of yesterday charge.',
        status: 'Insight',
        tags: const ['Solar', 'Analytics'],
        metricValue: 18,
        metricLabel: '% solar',
      ),
      ActivityEntry(
        id: 'activity-alert-1',
        category: ActivityCategory.alert,
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        title: 'Software update paused',
        description: 'Cabin climate request interrupted the auto install.',
        status: 'Action required',
        tags: const ['System'],
        pinned: true,
      ),
      ActivityEntry(
        id: 'activity-trip-2',
        category: ActivityCategory.trip,
        timestamp: now.subtract(const Duration(days: 2)),
        title: 'Adventure Pack downloaded',
        description: 'Offline maps and entertainment synced for weekend drive.',
        status: 'Ready',
        tags: const ['Offline'],
        resolved: true,
      ),
    ];
  }
}
