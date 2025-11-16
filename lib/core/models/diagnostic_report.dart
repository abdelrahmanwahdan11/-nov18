enum DiagnosticCategory { battery, charging, tires, software, climate, brakes }

class DiagnosticMetric {
  const DiagnosticMetric({
    required this.labelKey,
    required this.valueLabel,
    this.trendLabel,
  });

  final String labelKey;
  final String valueLabel;
  final String? trendLabel;
}

class DiagnosticReport {
  const DiagnosticReport({
    required this.id,
    required this.category,
    required this.health,
    required this.delta,
    required this.titleKey,
    required this.summaryKey,
    required this.metrics,
    required this.recommendationKeys,
    required this.updatedAt,
    this.critical = false,
  });

  final String id;
  final DiagnosticCategory category;
  final double health;
  final double delta;
  final String titleKey;
  final String summaryKey;
  final List<DiagnosticMetric> metrics;
  final List<String> recommendationKeys;
  final DateTime updatedAt;
  final bool critical;

  DiagnosticReport copyWith({
    double? health,
    double? delta,
    DateTime? updatedAt,
    bool? critical,
    List<DiagnosticMetric>? metrics,
  }) {
    return DiagnosticReport(
      id: id,
      category: category,
      health: (health ?? this.health).clamp(0.0, 1.0),
      delta: delta ?? this.delta,
      titleKey: titleKey,
      summaryKey: summaryKey,
      metrics: metrics ?? this.metrics,
      recommendationKeys: recommendationKeys,
      updatedAt: updatedAt ?? this.updatedAt,
      critical: critical ?? this.critical,
    );
  }
}

class DiagnosticTimelineEntry {
  const DiagnosticTimelineEntry({
    required this.id,
    required this.category,
    required this.titleKey,
    required this.detailKey,
    required this.timestamp,
    this.resolved = false,
  });

  final String id;
  final DiagnosticCategory category;
  final String titleKey;
  final String detailKey;
  final DateTime timestamp;
  final bool resolved;

  DiagnosticTimelineEntry copyWith({bool? resolved, DateTime? timestamp}) {
    return DiagnosticTimelineEntry(
      id: id,
      category: category,
      titleKey: titleKey,
      detailKey: detailKey,
      timestamp: timestamp ?? this.timestamp,
      resolved: resolved ?? this.resolved,
    );
  }
}
