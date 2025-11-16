import 'dart:async';

import 'package:flutter/material.dart';

import '../models/trip.dart';

class TripsController extends ChangeNotifier {
  TripsController() {
    _items = List.generate(
      8,
      (index) => Trip(
        id: 'trip-$index',
        title: 'Adventure Trip ${index + 1}',
        city: 'City ${index + 1}',
        distanceKm: 120 + index * 30,
        date: DateTime.now().add(Duration(days: index * 5)),
        description: 'Scenic trip number ${index + 1} with curated charging.',
      ),
    );
  }

  late List<Trip> _items;
  final StreamController<List<Trip>> _controller =
      StreamController<List<Trip>>.broadcast();

  Stream<List<Trip>> get tripsStream => _controller.stream;

  Future<void> load() async {
    await Future.delayed(const Duration(milliseconds: 900));
    _controller.add(_items);
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _items = _items.reversed.toList();
    _controller.add(_items);
  }

  void search(String query) {
    final list = _items
        .where((trip) =>
            trip.title.toLowerCase().contains(query.toLowerCase()) ||
            trip.city.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _controller.add(list);
  }
}
