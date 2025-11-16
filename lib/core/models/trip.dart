class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.city,
    required this.distanceKm,
    required this.date,
    required this.description,
    this.durationHours = 4.0,
    this.arrivalBattery = 0.25,
    this.chargingStops = const [],
    this.segments = const [],
    this.highlights = const [],
    this.weatherSummary = '22°C · Sunny',
    this.estimatedConsumption = 18.0,
  });

  final String id;
  final String title;
  final String city;
  final double distanceKm;
  final DateTime date;
  final String description;
  final double durationHours;
  final double arrivalBattery;
  final List<String> chargingStops;
  final List<TripSegment> segments;
  final List<String> highlights;
  final String weatherSummary;
  final double estimatedConsumption;
}

class TripSegment {
  const TripSegment({
    required this.label,
    required this.location,
    required this.distanceKm,
    required this.driveDuration,
    this.stopType = TripStopType.drive,
    this.note,
  });

  final String label;
  final String location;
  final double distanceKm;
  final Duration driveDuration;
  final TripStopType stopType;
  final String? note;
}

enum TripStopType { drive, charging, arrival }
