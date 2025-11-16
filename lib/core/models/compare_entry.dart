class CompareEntry {
  CompareEntry({
    required this.title,
    required this.stat,
    this.range,
    this.power,
    this.chargeSpeed,
    this.price,
    this.distance,
    this.availability,
  });

  final String title;
  final String stat;
  final String? range;
  final String? power;
  final String? chargeSpeed;
  final String? price;
  final String? distance;
  final String? availability;
}
