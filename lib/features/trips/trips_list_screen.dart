import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/trips_controller.dart';
import '../../core/models/trip.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/widgets/skeleton_list.dart';

class TripsListScreen extends StatefulWidget {
  const TripsListScreen({
    super.key,
    required this.controller,
    this.embedded = false,
  });

  final TripsController controller;
  final bool embedded;

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  bool loading = true;
  List<Trip> trips = [];
  StreamSubscription<List<Trip>>? subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.controller.tripsStream.listen((event) {
      setState(() {
        loading = false;
        trips = event;
      });
    });
    widget.controller.load();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? const Padding(
            padding: EdgeInsets.all(24),
            child: SkeletonList(),
          )
        : RefreshIndicator(
            onRefresh: widget.controller.refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppSearchBar(
                  onChanged: widget.controller.search,
                  hintText: 'Search trips',
                ),
                const SizedBox(height: 12),
                ...trips.map(
                  (trip) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppCard(
                      child: ListTile(
                        title: Text(trip.title),
                        subtitle: Text('${trip.city} · ${trip.distanceKm} km'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.tripDetails),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: content,
    );
  }
}
