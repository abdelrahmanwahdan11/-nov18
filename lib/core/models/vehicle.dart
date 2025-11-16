class Vehicle {
  Vehicle({
    required this.id,
    required this.name,
    required this.image,
    required this.range,
    required this.power,
    required this.speed,
    required this.batteryLevel,
  });

  final String id;
  final String name;
  final String image;
  final int range;
  final int power;
  final int speed;
  final double batteryLevel;
}
