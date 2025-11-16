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
}
