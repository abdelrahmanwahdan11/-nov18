class MaintenanceTask {
  MaintenanceTask({
    required this.id,
    required this.title,
    required this.currentMileage,
    required this.nextServiceMileage,
    required this.intervalDays,
    this.dueDate,
    this.notes,
    this.serviceCenter,
    this.requiresWorkshop = false,
    this.healthScore = 80,
  });

  final String id;
  final String title;
  final int currentMileage;
  final int nextServiceMileage;
  final int intervalDays;
  final DateTime? dueDate;
  final String? notes;
  final String? serviceCenter;
  final bool requiresWorkshop;
  final int healthScore;

  double get progress => currentMileage / nextServiceMileage;

  int get daysUntilDue => dueDate == null
      ? intervalDays
      : dueDate!.difference(DateTime.now()).inDays;

  bool get isDueSoon => daysUntilDue <= 30;

  String get dueLabel => dueDate == null
      ? 'Every $intervalDays days'
      : 'Due in ${daysUntilDue.clamp(0, intervalDays)} days';
}
