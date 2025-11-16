import 'package:flutter/material.dart';

import '../models/driving_tip.dart';

class CoachController extends ChangeNotifier {
  CoachController() {
    _tips = [
      DrivingTip(
        id: 'tip-1',
        title: 'Feather the accelerator in city traffic',
        description:
            'Stay below 30% pedal input for the first 5 seconds after each stop to cut energy spikes.',
        category: CoachCategory.efficiency,
        scoreImpact: 2.5,
        duration: 'Daily commutes',
        focus: 'City loops',
        badge: 'Smooth launch',
      ),
      DrivingTip(
        id: 'tip-2',
        title: 'Schedule cabin pre-conditioning',
        description:
            'Use shore power to warm the cabin before departure and avoid draining the pack.',
        category: CoachCategory.climate,
        scoreImpact: 1.5,
        duration: '15 min before departure',
        focus: 'Cold mornings',
      ),
      DrivingTip(
        id: 'tip-3',
        title: 'Charge between 20-80% on weekdays',
        description:
            'Keep the battery in the sweet spot unless you plan a long road trip in the next 48 hours.',
        category: CoachCategory.charging,
        scoreImpact: 3,
        duration: 'Weekday plan',
        focus: 'Battery longevity',
      ),
      DrivingTip(
        id: 'tip-4',
        title: 'Plan one-pedal driving routes',
        description:
            'Favor regenerative-friendly streets with gentle slopes inside the trip planner.',
        category: CoachCategory.planning,
        scoreImpact: 1.8,
        duration: 'Weekend trips',
        focus: 'Suburban drives',
      ),
      DrivingTip(
        id: 'tip-5',
        title: 'Rotate tire pressure checks',
        description:
            'Check one axle per week to keep the chassis balanced without a lengthy pit stop.',
        category: CoachCategory.safety,
        scoreImpact: 1.2,
        duration: '5 min stop',
        focus: 'Garage routine',
      ),
      DrivingTip(
        id: 'tip-6',
        title: 'Use eco climate profiles above 60 km/h',
        description:
            'Auto-moderate fan speed and vent mix on highway legs to save up to 4% range.',
        category: CoachCategory.climate,
        scoreImpact: 1.9,
        duration: 'Highway legs',
        focus: 'Long range',
      ),
    ];
  }

  late List<DrivingTip> _tips;
  CoachCategory? _category;
  bool _bookmarkedOnly = false;

  List<DrivingTip> get tips {
    Iterable<DrivingTip> data = _tips;
    if (_category != null) {
      data = data.where((tip) => tip.category == _category);
    }
    if (_bookmarkedOnly) {
      data = data.where((tip) => tip.bookmarked);
    }
    return data.toList();
  }

  List<DrivingTip> highlightTips([int count = 3]) {
    return _tips.where((tip) => !tip.completed).take(count).toList();
  }

  List<double> get weeklyTrend => const [72, 74, 76, 78, 79, 81, 83];

  Map<String, double> get focusBreakdown => const {
        'city': 42,
        'highway': 33,
        'climate': 15,
        'charging': 10,
      };

  double get ecoScore {
    final base = 74.0;
    final bonus = _tips
        .where((tip) => tip.completed)
        .fold<double>(0, (value, tip) => value + tip.scoreImpact);
    return (base + bonus).clamp(0, 100);
  }

  CoachCategory? get category => _category;
  bool get bookmarkedOnly => _bookmarkedOnly;

  void selectCategory(CoachCategory? category) {
    _category = category;
    notifyListeners();
  }

  void toggleBookmarkedOnly() {
    _bookmarkedOnly = !_bookmarkedOnly;
    notifyListeners();
  }

  void toggleBookmark(String id) {
    _tips = _tips
        .map((tip) =>
            tip.id == id ? tip.copyWith(bookmarked: !tip.bookmarked) : tip)
        .toList();
    notifyListeners();
  }

  void toggleCompleted(String id) {
    _tips = _tips
        .map((tip) =>
            tip.id == id ? tip.copyWith(completed: !tip.completed) : tip)
        .toList();
    notifyListeners();
  }

  Future<void> refreshRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_tips.isEmpty) return;
    final recycled = _tips.first;
    _tips = [
      ..._tips.skip(1),
      recycled.copyWith(
        completed: false,
        bookmarked: recycled.bookmarked,
        badge: recycled.badge,
      ),
    ];
    notifyListeners();
  }
}
