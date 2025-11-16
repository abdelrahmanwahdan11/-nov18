class MaintenanceTask {
  MaintenanceTask({
    required this.id,
    required this.title,
    required this.currentMileage,
    required this.nextServiceMileage,
    required this.intervalDays,
  });

  final String id;
  final String title;
  final int currentMileage;
  final int nextServiceMileage;
  final int intervalDays;

  double get progress => currentMileage / nextServiceMileage;
}
