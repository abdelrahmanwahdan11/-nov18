import 'dart:async';

import 'package:flutter/material.dart';

import '../models/trip.dart';

enum TripFilter { all, upcoming, past }

class TripsController extends ChangeNotifier {
  TripsController() {
    _items = List.generate(
      10,
      (index) {
        final scenic = index.isEven;
        return Trip(
          id: 'trip-$index',
          title: scenic ? 'Alpine Escape ${index + 1}' : 'Coastal Sprint ${index + 1}',
          city: scenic ? 'Munich' : 'Dubai',
          distanceKm: 140 + index * 45,
          date: DateTime.now().add(Duration(days: index - 2)),
          durationHours: 2.5 + index * .4,
          arrivalBattery: 0.15 + index * 0.03,
          estimatedConsumption: 17 + index,
          weatherSummary: scenic ? '18°C · Clear skies' : '32°C · Breezy',
          chargingStops: const [
            'Ionity Hub',
            'City Center Plaza',
            'BMW Lounge'
          ],
          segments: [
            TripSegment(
              label: 'Departure',
              location: scenic ? 'BMW HQ Munich' : 'Dubai Marina',
              distanceKm: 0,
              driveDuration: Duration.zero,
              note: 'Leave 08:00 · battery pre-conditioned',
            ),
            TripSegment(
              label: 'Cruise',
              location: scenic ? 'Alps ridge' : 'Desert highway',
              distanceKm: 120 + index * 10,
              driveDuration: Duration(hours: 1, minutes: 40),
              note: 'Adaptive drive engaged',
            ),
            TripSegment(
              label: 'Charging stop',
              location: scenic ? 'Ionity Hub' : 'City Center Plaza',
              distanceKm: 0,
              driveDuration: const Duration(minutes: 35),
              stopType: TripStopType.charging,
              note: 'Top up to 80%',
            ),
            TripSegment(
              label: 'Arrival',
              location: scenic ? 'Innsbruck' : 'Abu Dhabi',
              distanceKm: 180 + index * 20,
              driveDuration: Duration(hours: 2, minutes: 10),
              stopType: TripStopType.arrival,
              note: 'Hotel valet charging reserved',
            ),
          ],
          highlights: scenic
              ? const ['Alpine tunnels', 'Smart regen saves 8%', 'Ionity lounge break']
              : const ['Desert autopilot lane', 'Cabin cooled automatically'],
          description: 'Scenic trip number ${index + 1} with curated charging.',
        );
      },
    );
    _filtered = List.from(_items);
    _visible = [];
  }

  late List<Trip> _items;
  late List<Trip> _filtered;
  List<Trip> _visible = [];
  final StreamController<List<Trip>> _controller =
      StreamController<List<Trip>>.broadcast();
  final int _pageSize = 4;
  int _page = 1;
  TripFilter _filter = TripFilter.all;
  double? _maxDistance;
  String _query = '';

  Stream<List<Trip>> get tripsStream => _controller.stream;
  List<Trip> get visibleTrips => List.unmodifiable(_visible);
  Trip? get nextTrip {
    final futureTrips = _items
        .where((trip) => trip.date.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return futureTrips.isEmpty ? null : futureTrips.first;
  }

  bool get canLoadMore => _visible.length < _filtered.length;

  Future<void> load() async {
    await Future.delayed(const Duration(milliseconds: 900));
    _applyFilters();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _items.shuffle();
    _applyFilters();
  }

  Future<void> loadMore() async {
    if (!canLoadMore) return;
    _page++;
    await Future.delayed(const Duration(milliseconds: 400));
    _applyFilters(resetPage: false);
  }

  void search(String query) {
    _query = query;
    _applyFilters();
  }

  void setFilter(TripFilter filter) {
    _filter = filter;
    _applyFilters();
  }

  void setDistanceFilter(double? maxDistance) {
    _maxDistance = maxDistance;
    _applyFilters();
  }

  void addTrip(Trip trip) {
    _items.insert(0, trip);
    _applyFilters();
  }

  void _applyFilters({bool resetPage = true}) {
    Iterable<Trip> list = _items;
    if (_query.isNotEmpty) {
      list = list.where((trip) =>
          trip.title.toLowerCase().contains(_query.toLowerCase()) ||
          trip.city.toLowerCase().contains(_query.toLowerCase()));
    }
    if (_filter == TripFilter.upcoming) {
      list = list.where((trip) => trip.date.isAfter(DateTime.now()));
    } else if (_filter == TripFilter.past) {
      list = list.where((trip) => trip.date.isBefore(DateTime.now()));
    }
    if (_maxDistance != null) {
      list = list.where((trip) => trip.distanceKm <= _maxDistance!);
    }
    _filtered = list.toList();
    if (resetPage) {
      _page = 1;
    }
    final takeCount =
        (_page * _pageSize).clamp(0, _filtered.length).toInt();
    _visible = _filtered.take(takeCount).toList();
    _controller.add(_visible);
  }
}
