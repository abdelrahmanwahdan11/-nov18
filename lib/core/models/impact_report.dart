class ImpactSummary {
  ImpactSummary({
    required this.carbonSavedKg,
    required this.renewableShare,
    required this.treeEquivalent,
    required this.energyRegainedKwh,
    required this.ecoScore,
    required this.smartTrips,
    required this.highlights,
  });

  final double carbonSavedKg;
  final double renewableShare;
  final double treeEquivalent;
  final double energyRegainedKwh;
  final double ecoScore;
  final int smartTrips;
  final List<String> highlights;

  ImpactSummary copyWith({
    double? carbonSavedKg,
    double? renewableShare,
    double? treeEquivalent,
    double? energyRegainedKwh,
    double? ecoScore,
    int? smartTrips,
    List<String>? highlights,
  }) {
    return ImpactSummary(
      carbonSavedKg: carbonSavedKg ?? this.carbonSavedKg,
      renewableShare: renewableShare ?? this.renewableShare,
      treeEquivalent: treeEquivalent ?? this.treeEquivalent,
      energyRegainedKwh: energyRegainedKwh ?? this.energyRegainedKwh,
      ecoScore: ecoScore ?? this.ecoScore,
      smartTrips: smartTrips ?? this.smartTrips,
      highlights: highlights ?? this.highlights,
    );
  }
}

class ImpactTrendPoint {
  ImpactTrendPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class ImpactAchievement {
  ImpactAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final double progress;
  final bool unlocked;

  ImpactAchievement copyWith({double? progress, bool? unlocked}) {
    return ImpactAchievement(
      id: id,
      title: title,
      description: description,
      progress: progress ?? this.progress,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}

class ImpactActionPlan {
  ImpactActionPlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.potential,
    this.bookmarked = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final double potential;
  bool bookmarked;
}

class ImpactReportEntry {
  ImpactReportEntry({
    required this.id,
    required this.period,
    required this.summary,
    required this.energyUsed,
    required this.energyFromRenewables,
    required this.recommendation,
  });

  final String id;
  final String period;
  final double energyUsed;
  final double energyFromRenewables;
  final String summary;
  final String recommendation;
}
