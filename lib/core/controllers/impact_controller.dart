import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/impact_report.dart';
import '../storage/preferences_service.dart';

class ImpactController extends ChangeNotifier {
  ImpactController() {
    _hydrate();
  }

  static const _goalKey = 'impact_goal_target';
  final _prefs = PreferencesService.instance;
  final _random = Random();

  ImpactSummary _summary = ImpactSummary(
    carbonSavedKg: 428.0,
    renewableShare: .67,
    treeEquivalent: 18.0,
    energyRegainedKwh: 122.0,
    ecoScore: 86,
    smartTrips: 42,
    highlights: [
      'Regenerative braking covered 23 km last week',
      'Solar charging added 9.3 kWh on Sunday',
      'Eco route avoided 12 kg of CO₂',
    ],
  );

  double _goal = 80;
  bool _loading = false;
  DateTime? _lastExport;

  final List<ImpactTrendPoint> _weeklyTrend = [
    ImpactTrendPoint(label: 'Mon', value: 72),
    ImpactTrendPoint(label: 'Tue', value: 85),
    ImpactTrendPoint(label: 'Wed', value: 61),
    ImpactTrendPoint(label: 'Thu', value: 90),
    ImpactTrendPoint(label: 'Fri', value: 78),
    ImpactTrendPoint(label: 'Sat', value: 96),
    ImpactTrendPoint(label: 'Sun', value: 88),
  ];

  final Map<String, double> _energyMix = {
    'solar': 0.34,
    'wind': 0.18,
    'grid': 0.33,
    'regen': 0.15,
  };

  final List<ImpactAchievement> _achievements = [
    ImpactAchievement(
      id: 'trees',
      title: 'Forest Guardian',
      description: 'Plant the equivalent of 20 trees with smart driving.',
      progress: .75,
      unlocked: true,
    ),
    ImpactAchievement(
      id: 'renewable',
      title: 'Renewable Champion',
      description: 'Charge 70% from renewable sources for a week.',
      progress: .54,
      unlocked: false,
    ),
    ImpactAchievement(
      id: 'coach',
      title: 'Coached Explorer',
      description: 'Complete 5 AI coach actions in a month.',
      progress: .32,
      unlocked: false,
    ),
  ];

  final List<ImpactActionPlan> _actions = [
    ImpactActionPlan(
      id: 'homeSolar',
      title: 'Boost home solar charging',
      subtitle: 'Shift 18% more top-ups to daytime when panels peak.',
      potential: 0.18,
    ),
    ImpactActionPlan(
      id: 'smartRoutes',
      title: 'Adopt scenic eco routes',
      subtitle: 'Use AI routing to avoid steep climbs and traffic jams.',
      potential: 0.12,
    ),
    ImpactActionPlan(
      id: 'communityCharge',
      title: 'Schedule community chargers',
      subtitle: 'Reserve slower chargers overnight to stay green.',
      potential: 0.07,
    ),
  ];

  final List<ImpactReportEntry> _reports = [
    ImpactReportEntry(
      id: 'apr',
      period: 'April 2024',
      summary: '38% lower emissions vs. city average.',
      energyUsed: 211,
      energyFromRenewables: 0.71,
      recommendation: 'Enable auto-schedule for the next road trip.',
    ),
    ImpactReportEntry(
      id: 'mar',
      period: 'March 2024',
      summary: 'New record for solar kWh captured.',
      energyUsed: 226,
      energyFromRenewables: 0.64,
      recommendation: 'Keep tire pressures balanced before long drives.',
    ),
  ];

  ImpactSummary get summary => _summary;
  List<ImpactTrendPoint> get weeklyTrend => List.unmodifiable(_weeklyTrend);
  Map<String, double> get energyMix => Map.unmodifiable(_energyMix);
  List<ImpactAchievement> get achievements => List.unmodifiable(_achievements);
  List<ImpactActionPlan> get actions => List.unmodifiable(_actions);
  List<ImpactReportEntry> get reports => List.unmodifiable(_reports);
  double get goal => _goal;
  bool get loading => _loading;
  DateTime? get lastExport => _lastExport;

  Future<void> _hydrate() async {
    final savedGoal = await _prefs.getInt(_goalKey, defaultValue: _goal.round());
    _goal = savedGoal.toDouble();
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    _summary = _summary.copyWith(
      carbonSavedKg: (_summary.carbonSavedKg + _random.nextDouble() * 5).clamp(0, 9999),
      energyRegainedKwh:
          (_summary.energyRegainedKwh + _random.nextDouble() * 3).clamp(0, 9999),
      ecoScore: (_summary.ecoScore + _random.nextInt(3) - 1).clamp(60, 100).toDouble(),
      smartTrips: _summary.smartTrips + _random.nextInt(2),
    );
    for (var i = 0; i < _weeklyTrend.length; i++) {
      final base = _weeklyTrend[i].value;
      final jitter = base + _random.nextInt(6) - 3;
      _weeklyTrend[i] = ImpactTrendPoint(
        label: _weeklyTrend[i].label,
        value: jitter.clamp(50, 110).toDouble(),
      );
    }
    for (var i = 0; i < _achievements.length; i++) {
      final ach = _achievements[i];
      final gain = _random.nextDouble() * 0.05;
      final newProgress = (ach.progress + gain).clamp(0, 1);
      _achievements[i] = ach.copyWith(
        progress: newProgress,
        unlocked: ach.unlocked || newProgress >= 1,
      );
    }
    _loading = false;
    notifyListeners();
  }

  void updateGoal(double value) {
    _goal = value;
    _prefs.setInt(_goalKey, value.round());
    notifyListeners();
  }

  void toggleActionBookmark(String id) {
    final plan = _actions.firstWhere((element) => element.id == id);
    plan.bookmarked = !plan.bookmarked;
    notifyListeners();
  }

  DateTime exportDigest() {
    _lastExport = DateTime.now();
    notifyListeners();
    return _lastExport!;
  }
}
