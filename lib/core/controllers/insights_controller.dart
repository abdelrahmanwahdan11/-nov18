import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/insight.dart';

class InsightsController extends ChangeNotifier {
  InsightsController() {
    _insights = List.of(_seedInsights);
  }

  final math.Random _random = math.Random();
  late List<Insight> _insights;
  bool _loading = false;
  Map<String, double> _weeklyEfficiency = _buildWeeklyTrend();
  Map<String, double> _energyMix = _buildEnergyMix();

  bool get loading => _loading;
  List<Insight> get insights => List.unmodifiable(_insights);
  List<Insight> get pinned =>
      List.unmodifiable(_insights.where((insight) => insight.pinned));
  List<Insight> get highlights => _insights.take(3).toList();
  Map<String, double> get weeklyEfficiency => _weeklyEfficiency;
  Map<String, double> get energyMix => _energyMix;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 750));
    _insights = _insights
        .map(
          (insight) => insight.copyWith(
            impact: (insight.impact + (_random.nextDouble() * 0.12 - 0.06))
                .clamp(0.48, 0.98),
            trend: insight.trend + _random.nextInt(7) - 3,
            acknowledged: false,
          ),
        )
        .toList()
      ..shuffle(_random);
    _weeklyEfficiency = _buildWeeklyTrend();
    _energyMix = _buildEnergyMix();
    _loading = false;
    notifyListeners();
  }

  void togglePin(String id) {
    final index = _insights.indexWhere((insight) => insight.id == id);
    if (index == -1) return;
    final current = _insights[index];
    _insights[index] = current.copyWith(pinned: !current.pinned);
    notifyListeners();
  }

  void acknowledge(String id) {
    final index = _insights.indexWhere((insight) => insight.id == id);
    if (index == -1) return;
    final current = _insights[index];
    _insights[index] = current.copyWith(acknowledged: !current.acknowledged);
    notifyListeners();
  }

  void resetDemo() {
    _insights = List.of(_seedInsights);
    notifyListeners();
  }

  static Map<String, double> _buildWeeklyTrend() {
    final random = math.Random();
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return {
      for (final day in days) day: 70 + random.nextInt(20) + random.nextDouble()
    };
  }

  static Map<String, double> _buildEnergyMix() {
    final random = math.Random();
    final solar = 25 + random.nextInt(25);
    final grid = 50 + random.nextInt(15);
    final regen = 100 - solar - grid;
    return {
      'solar': solar.toDouble(),
      'grid': grid.toDouble(),
      'regen': regen.toDouble(),
    };
  }
}

const List<Insight> _seedInsights = [
  Insight(
    id: 'efficiency-boost',
    title: 'Efficiency up 9%',
    description: 'Smart coasting and eco routes saved extra range this week.',
    category: InsightCategory.efficiency,
    impact: 0.91,
    trend: 9,
    action: 'Keep eco route active during city commutes.',
    timestamp: DateTime.now(),
    pinned: true,
  ),
  Insight(
    id: 'charging-window',
    title: 'Night window optimized',
    description: 'Charging between 1-4 AM reduced costs by 17%.',
    category: InsightCategory.charging,
    impact: 0.84,
    trend: -2,
    action: 'Extend the low-tariff window to 5 AM on weekdays.',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  Insight(
    id: 'trip-ready',
    title: 'Mountain trip ready',
    description: 'Battery preconditioning scheduled for tomorrow’s climb.',
    category: InsightCategory.trips,
    impact: 0.76,
    trend: 4,
    action: 'Confirm tire pressure before departure.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Insight(
    id: 'maintenance-plan',
    title: 'Brake service postponed',
    description: 'Regenerative braking reduced wear by 12%.',
    category: InsightCategory.maintenance,
    impact: 0.64,
    trend: -1,
    action: 'Review maintenance plan next week.',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Insight(
    id: 'comfort-coach',
    title: 'Cabin comfort steady',
    description: 'Preheat routine keeps passengers comfortable with minimal draw.',
    category: InsightCategory.driving,
    impact: 0.58,
    trend: 3,
    action: 'Test smart-vent automation for afternoon drives.',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
