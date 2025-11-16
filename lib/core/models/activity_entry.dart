import 'package:flutter/material.dart';

enum ActivityCategory { charging, trip, maintenance, energy, alert }

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.category,
    required this.timestamp,
    required this.title,
    required this.description,
    this.status,
    this.progress,
    this.tags = const [],
    this.pinned = false,
    this.resolved = false,
    this.metricValue,
    this.metricLabel,
  });

  final String id;
  final ActivityCategory category;
  final DateTime timestamp;
  final String title;
  final String description;
  final String? status;
  final double? progress;
  final List<String> tags;
  final bool pinned;
  final bool resolved;
  final double? metricValue;
  final String? metricLabel;

  Color categoryColor(ColorScheme scheme) {
    switch (category) {
      case ActivityCategory.charging:
        return scheme.primary;
      case ActivityCategory.trip:
        return scheme.tertiaryContainer;
      case ActivityCategory.maintenance:
        return scheme.errorContainer;
      case ActivityCategory.energy:
        return scheme.secondary;
      case ActivityCategory.alert:
        return scheme.outline;
    }
  }

  ActivityEntry copyWith({
    ActivityCategory? category,
    DateTime? timestamp,
    String? title,
    String? description,
    String? status,
    double? progress,
    List<String>? tags,
    bool? pinned,
    bool? resolved,
    double? metricValue,
    String? metricLabel,
  }) {
    return ActivityEntry(
      id: id,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      tags: tags ?? this.tags,
      pinned: pinned ?? this.pinned,
      resolved: resolved ?? this.resolved,
      metricValue: metricValue ?? this.metricValue,
      metricLabel: metricLabel ?? this.metricLabel,
    );
  }
}
