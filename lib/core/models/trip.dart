class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.city,
    required this.distanceKm,
    required this.date,
    required this.description,
  });

  final String id;
  final String title;
  final String city;
  final double distanceKm;
  final DateTime date;
  final String description;
}
