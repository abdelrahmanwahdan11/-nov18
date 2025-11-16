class ChargingSession {
  ChargingSession({
    required this.id,
    required this.station,
    required this.startTime,
    required this.endTime,
    required this.energyKwh,
    required this.cost,
    required this.status,
  });

  final String id;
  final String station;
  final DateTime startTime;
  final DateTime endTime;
  final double energyKwh;
  final double cost;
  final ChargingStatus status;

  Duration get duration => endTime.difference(startTime);
}

class ChargingSchedule {
  ChargingSchedule({
    required this.title,
    required this.window,
    required this.limit,
    this.autoStart = true,
  });

  final String title;
  final String window;
  final int limit;
  final bool autoStart;
}

enum ChargingStatus { running, completed, queued }
