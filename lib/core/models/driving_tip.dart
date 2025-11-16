import 'package:flutter/material.dart';

enum CoachCategory { efficiency, climate, charging, planning, safety }

extension CoachCategoryX on CoachCategory {
  String get id => name;

  IconData get icon {
    switch (this) {
      case CoachCategory.efficiency:
        return Icons.auto_graph_rounded;
      case CoachCategory.climate:
        return Icons.ac_unit_rounded;
      case CoachCategory.charging:
        return Icons.ev_station_rounded;
      case CoachCategory.planning:
        return Icons.route_rounded;
      case CoachCategory.safety:
        return Icons.shield_moon_rounded;
    }
  }
}

class DrivingTip {
  const DrivingTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.scoreImpact,
    required this.duration,
    required this.focus,
    this.completed = false,
    this.bookmarked = false,
    this.badge,
  });

  final String id;
  final String title;
  final String description;
  final CoachCategory category;
  final double scoreImpact;
  final String duration;
  final String focus;
  final bool completed;
  final bool bookmarked;
  final String? badge;

  DrivingTip copyWith({
    String? id,
    String? title,
    String? description,
    CoachCategory? category,
    double? scoreImpact,
    String? duration,
    String? focus,
    bool? completed,
    bool? bookmarked,
    String? badge,
  }) {
    return DrivingTip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      scoreImpact: scoreImpact ?? this.scoreImpact,
      duration: duration ?? this.duration,
      focus: focus ?? this.focus,
      completed: completed ?? this.completed,
      bookmarked: bookmarked ?? this.bookmarked,
      badge: badge ?? this.badge,
    );
  }
}
