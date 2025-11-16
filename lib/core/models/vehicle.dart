class Vehicle {
  Vehicle({
    required this.id,
    required this.name,
    required this.image,
    required this.range,
    required this.power,
    required this.speed,
    required this.batteryLevel,
    this.odometer = 0,
    this.efficiency = 0,
    this.drivetrain = 'AWD',
    this.healthScore = 90,
    this.isFavorite = false,
    DateTime? lastService,
    this.batteryType = 'Li-ion',
  }) : lastService = lastService ?? DateTime.now();

  final String id;
  final String name;
  final String image;
  final int range;
  final int power;
  final int speed;
  final double batteryLevel;
  final int odometer;
  final int efficiency; // Wh/km equivalent
  final String drivetrain;
  final int healthScore;
  final bool isFavorite;
  final DateTime lastService;
  final String batteryType;

  Vehicle copyWith({
    String? id,
    String? name,
    String? image,
    int? range,
    int? power,
    int? speed,
    double? batteryLevel,
    int? odometer,
    int? efficiency,
    String? drivetrain,
    int? healthScore,
    bool? isFavorite,
    DateTime? lastService,
    String? batteryType,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      range: range ?? this.range,
      power: power ?? this.power,
      speed: speed ?? this.speed,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      odometer: odometer ?? this.odometer,
      efficiency: efficiency ?? this.efficiency,
      drivetrain: drivetrain ?? this.drivetrain,
      healthScore: healthScore ?? this.healthScore,
      isFavorite: isFavorite ?? this.isFavorite,
      lastService: lastService ?? this.lastService,
      batteryType: batteryType ?? this.batteryType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'range': range,
      'power': power,
      'speed': speed,
      'batteryLevel': batteryLevel,
      'odometer': odometer,
      'efficiency': efficiency,
      'drivetrain': drivetrain,
      'healthScore': healthScore,
      'isFavorite': isFavorite,
      'lastService': lastService.toIso8601String(),
      'batteryType': batteryType,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
      range: map['range'] as int,
      power: map['power'] as int,
      speed: map['speed'] as int,
      batteryLevel: (map['batteryLevel'] as num).toDouble(),
      odometer: map['odometer'] as int? ?? 0,
      efficiency: map['efficiency'] as int? ?? 0,
      drivetrain: map['drivetrain'] as String? ?? 'AWD',
      healthScore: map['healthScore'] as int? ?? 90,
      isFavorite: map['isFavorite'] as bool? ?? false,
      lastService: map['lastService'] != null
          ? DateTime.tryParse(map['lastService'] as String) ?? DateTime.now()
          : DateTime.now(),
      batteryType: map['batteryType'] as String? ?? 'Li-ion',
    );
  }
}
