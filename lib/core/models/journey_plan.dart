class JourneyPlan {
  const JourneyPlan({
    required this.id,
    required this.title,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationHours,
    required this.stops,
    required this.bufferPercent,
    required this.chargeLimit,
    required this.weather,
    required this.energyCost,
    required this.departure,
    required this.mapImage,
    required this.aiNote,
    this.isFavorite = false,
    this.focus = 'eco',
    this.autoAdjustClimate = true,
  });

  final String id;
  final String title;
  final String origin;
  final String destination;
  final double distanceKm;
  final double durationHours;
  final List<String> stops;
  final double bufferPercent;
  final double chargeLimit;
  final String weather;
  final double energyCost;
  final DateTime departure;
  final String mapImage;
  final String aiNote;
  final bool isFavorite;
  final String focus;
  final bool autoAdjustClimate;

  JourneyPlan copyWith({
    String? id,
    String? title,
    String? origin,
    String? destination,
    double? distanceKm,
    double? durationHours,
    List<String>? stops,
    double? bufferPercent,
    double? chargeLimit,
    String? weather,
    double? energyCost,
    DateTime? departure,
    String? mapImage,
    String? aiNote,
    bool? isFavorite,
    String? focus,
    bool? autoAdjustClimate,
  }) {
    return JourneyPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      distanceKm: distanceKm ?? this.distanceKm,
      durationHours: durationHours ?? this.durationHours,
      stops: stops ?? List<String>.from(this.stops),
      bufferPercent: bufferPercent ?? this.bufferPercent,
      chargeLimit: chargeLimit ?? this.chargeLimit,
      weather: weather ?? this.weather,
      energyCost: energyCost ?? this.energyCost,
      departure: departure ?? this.departure,
      mapImage: mapImage ?? this.mapImage,
      aiNote: aiNote ?? this.aiNote,
      isFavorite: isFavorite ?? this.isFavorite,
      focus: focus ?? this.focus,
      autoAdjustClimate: autoAdjustClimate ?? this.autoAdjustClimate,
    );
  }
}
