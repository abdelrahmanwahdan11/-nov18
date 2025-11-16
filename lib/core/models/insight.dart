import 'package:flutter/material.dart';

enum InsightCategory { efficiency, charging, trips, maintenance, driving }

extension InsightCategoryX on InsightCategory {
  String get id => name;

  IconData get icon {
    switch (this) {
      case InsightCategory.efficiency:
        return Icons.auto_graph_rounded;
      case InsightCategory.charging:
        return Icons.bolt_rounded;
      case InsightCategory.trips:
        return Icons.route_outlined;
      case InsightCategory.maintenance:
        return Icons.build_circle_rounded;
      case InsightCategory.driving:
        return Icons.stacked_line_chart;
    }
  }
}

class Insight {
  const Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.impact,
    required this.trend,
    required this.action,
    required this.timestamp,
    this.pinned = false,
    this.acknowledged = false,
  });

  final String id;
  final String title;
  final String description;
  final InsightCategory category;
  final double impact;
  final int trend;
  final String action;
  final DateTime timestamp;
  final bool pinned;
  final bool acknowledged;

  Insight copyWith({
    String? id,
    String? title,
    String? description,
    InsightCategory? category,
    double? impact,
    int? trend,
    String? action,
    DateTime? timestamp,
    bool? pinned,
    bool? acknowledged,
  }) {
    return Insight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      impact: impact ?? this.impact,
      trend: trend ?? this.trend,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      pinned: pinned ?? this.pinned,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }
}
