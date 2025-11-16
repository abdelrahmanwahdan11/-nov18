import 'dart:async';

import 'package:flutter/material.dart';

import '../models/trip.dart';

enum TripFilter { all, upcoming, past }

class TripsController extends ChangeNotifier {
  TripsController() {
    _items = List.generate(
      10,
      (index) => Trip(
        id: 'trip-$index',
        title: 'Adventure Trip ${index + 1}',
        city: index.isEven ? 'Munich' : 'Dubai',
        distanceKm: 140 + index * 45,
        date: DateTime.now().add(Duration(days: index - 2)),
        durationHours: 2.5 + index * .4,
        arrivalBattery: 0.15 + index * 0.03,
        chargingStops: const [
          'Ionity Hub',
          'City Center Plaza',
          'BMW Lounge'
        ],
        description: 'Scenic trip number ${index + 1} with curated charging.',
      ),
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
