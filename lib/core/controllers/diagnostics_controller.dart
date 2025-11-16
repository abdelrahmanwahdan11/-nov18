import 'dart:math';

import 'package:flutter/material.dart';

import '../models/diagnostic_report.dart';

class DiagnosticsController extends ChangeNotifier {
  DiagnosticsController() {
    _load();
  }

  bool _loading = true;
  DateTime? _lastScan;
  DiagnosticCategory? _filter;
  List<DiagnosticReport> _reports = const [];
  List<DiagnosticTimelineEntry> _timeline = const [];

  bool get loading => _loading;
  DateTime? get lastScan => _lastScan;
  DiagnosticCategory? get filter => _filter;

  double get overallHealth {
    if (_reports.isEmpty) return 1;
    final total = _reports.fold<double>(0, (sum, item) => sum + item.health);
    return total / _reports.length;
  }

  int get criticalCount =>
      _reports.where((report) => report.critical || report.health < 0.6).length;

  List<DiagnosticReport> get reports => List.unmodifiable(_reports);

  List<DiagnosticReport> get filteredReports {
    if (_filter == null) return reports;
    return List.unmodifiable(
      _reports.where((report) => report.category == _filter),
    );
  }

  List<DiagnosticTimelineEntry> get filteredTimeline {
    if (_filter == null) return List.unmodifiable(_timeline);
    return List.unmodifiable(
      _timeline.where((entry) => entry.category == _filter),
    );
  }

  List<String> get recommendations {
    final List<String> items = [];
    for (final report in _reports) {
      items.addAll(report.recommendationKeys);
    }
    return items.toSet().toList();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _reports = _seedReports();
    _timeline = _seedTimeline();
    _lastScan = DateTime.now().subtract(const Duration(hours: 4));
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    final random = Random();
    _reports = _reports
        .map(
          (report) => report.copyWith(
            health: (report.health + (random.nextDouble() * 0.08 - 0.04))
                .clamp(0.45, 0.99),
            delta: (random.nextDouble() * 4 - 2) / 100,
            updatedAt: DateTime.now(),
            critical: report.critical && random.nextBool()
                ? true
                : report.health < 0.58,
          ),
        )
        .toList();
    _timeline = _timeline
        .map(
          (entry) => random.nextBool()
              ? entry
              : entry.copyWith(
                  timestamp: DateTime.now().subtract(
                    Duration(hours: random.nextInt(48)),
                  ),
                ),
        )
        .toList();
    _lastScan = DateTime.now();
    _loading = false;
    notifyListeners();
  }

  void setFilter(DiagnosticCategory? category) {
    _filter = category;
    notifyListeners();
  }

  void toggleResolved(String id) {
    final index = _timeline.indexWhere((entry) => entry.id == id);
    if (index == -1) return;
    final entry = _timeline[index];
    _timeline[index] = entry.copyWith(resolved: !entry.resolved);
    notifyListeners();
  }

  List<DiagnosticReport> _seedReports() {
    final now = DateTime.now();
    return [
      DiagnosticReport(
        id: 'battery',
        category: DiagnosticCategory.battery,
        health: 0.78,
        delta: -0.01,
        titleKey: 'diagnosticsBattery',
        summaryKey: 'diagnosticsBatterySummary',
        recommendationKeys: const [
          'diagnosticsRecBatteryCells',
          'diagnosticsRecBatteryPrecondition',
        ],
        metrics: const [
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricCellBalance',
            valueLabel: '98%',
            trendLabel: '+2%',
          ),
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricPackTemp',
            valueLabel: '34°C',
            trendLabel: '+3°',
          ),
        ],
        updatedAt: now,
        critical: false,
      ),
      DiagnosticReport(
        id: 'charging',
        category: DiagnosticCategory.charging,
        health: 0.71,
        delta: 0.03,
        titleKey: 'diagnosticsCharging',
        summaryKey: 'diagnosticsChargingSummary',
        recommendationKeys: const [
          'diagnosticsRecChargingSchedule',
        ],
        metrics: const [
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricChargeLimit',
            valueLabel: '82%',
            trendLabel: '+5%',
          ),
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricSessionDrift',
            valueLabel: '-4%',
            trendLabel: '-1%',
          ),
        ],
        updatedAt: now,
      ),
      DiagnosticReport(
        id: 'tires',
        category: DiagnosticCategory.tires,
        health: 0.64,
        delta: -0.02,
        titleKey: 'diagnosticsTires',
        summaryKey: 'diagnosticsTiresSummary',
        recommendationKeys: const [
          'diagnosticsRecTirePressure',
        ],
        metrics: const [
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricPressureFront',
            valueLabel: '38 psi',
            trendLabel: '-1',
          ),
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricPressureRear',
            valueLabel: '36 psi',
            trendLabel: '-2',
          ),
        ],
        updatedAt: now,
        critical: true,
      ),
      DiagnosticReport(
        id: 'software',
        category: DiagnosticCategory.software,
        health: 0.92,
        delta: 0.01,
        titleKey: 'diagnosticsSoftware',
        summaryKey: 'diagnosticsSoftwareSummary',
        recommendationKeys: const [
          'diagnosticsRecSoftwareUpdate',
        ],
        metrics: const [
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricVersion',
            valueLabel: '11.2.3',
          ),
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricUpdateAge',
            valueLabel: '23 days',
          ),
        ],
        updatedAt: now,
      ),
      DiagnosticReport(
        id: 'climate',
        category: DiagnosticCategory.climate,
        health: 0.74,
        delta: 0.00,
        titleKey: 'diagnosticsClimate',
        summaryKey: 'diagnosticsClimateSummary',
        recommendationKeys: const [
          'diagnosticsRecClimateFilter',
        ],
        metrics: const [
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricFilter',
            valueLabel: '68%',
          ),
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricHumidity',
            valueLabel: '47%',
          ),
        ],
        updatedAt: now,
      ),
      DiagnosticReport(
        id: 'brakes',
        category: DiagnosticCategory.brakes,
        health: 0.69,
        delta: -0.03,
        titleKey: 'diagnosticsBrakes',
        summaryKey: 'diagnosticsBrakesSummary',
        recommendationKeys: const [
          'diagnosticsRecBrakeBleed',
          'diagnosticsRecBrakePads',
        ],
        metrics: const [
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricPadWear',
            valueLabel: '54%',
            trendLabel: '-6%',
          ),
          DiagnosticMetric(
            labelKey: 'diagnosticsMetricFluidQuality',
            valueLabel: '78%',
          ),
        ],
        updatedAt: now,
      ),
    ];
  }

  List<DiagnosticTimelineEntry> _seedTimeline() {
    final now = DateTime.now();
    return [
      DiagnosticTimelineEntry(
        id: 'timeline-battery',
        category: DiagnosticCategory.battery,
        titleKey: 'diagnosticsEventBatteryTitle',
        detailKey: 'diagnosticsEventBatteryDetail',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      DiagnosticTimelineEntry(
        id: 'timeline-tires',
        category: DiagnosticCategory.tires,
        titleKey: 'diagnosticsEventTiresTitle',
        detailKey: 'diagnosticsEventTiresDetail',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
      DiagnosticTimelineEntry(
        id: 'timeline-software',
        category: DiagnosticCategory.software,
        titleKey: 'diagnosticsEventSoftwareTitle',
        detailKey: 'diagnosticsEventSoftwareDetail',
        timestamp: now.subtract(const Duration(hours: 18)),
        resolved: true,
      ),
      DiagnosticTimelineEntry(
        id: 'timeline-brakes',
        category: DiagnosticCategory.brakes,
        titleKey: 'diagnosticsEventBrakesTitle',
        detailKey: 'diagnosticsEventBrakesDetail',
        timestamp: now.subtract(const Duration(hours: 26)),
      ),
    ];
  }
}
