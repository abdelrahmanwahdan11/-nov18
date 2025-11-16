import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/trips_controller.dart';
import '../../core/models/compare_entry.dart';
import '../../core/models/trip.dart';
import '../../core/widgets/ai_info_button.dart';
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
  bool loadingMore = false;
  List<Trip> trips = [];
  TripFilter filter = TripFilter.all;
  double? distanceFilter;
  final Set<String> _compare = {};
  StreamSubscription<List<Trip>>? subscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    subscription = widget.controller.tripsStream.listen((event) {
      setState(() {
        loading = false;
        trips = event;
        loadingMore = false;
      });
    });
    widget.controller.load();
  }

  @override
  void dispose() {
    subscription?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || loadingMore) return;
    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent - 120 &&
        widget.controller.canLoadMore) {
      setState(() => loadingMore = true);
      widget.controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = loading
        ? const Padding(
            padding: EdgeInsets.all(24),
            child: SkeletonList(),
          )
        : RefreshIndicator(
            onRefresh: widget.controller.refresh,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                AppSearchBar(
                  onChanged: widget.controller.search,
                  hintText: 'Search trips',
                ),
                const SizedBox(height: 12),
                Row(
                  children: TripFilter.values
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(item.name.toUpperCase()),
                            selected: filter == item,
                            onSelected: (_) {
                              setState(() => filter = item);
                              widget.controller.setFilter(item);
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    (null, 'Any distance'),
                    (200.0, '< 200 km'),
                    (400.0, '< 400 km'),
                  ]
                      .map(
                        (option) => FilterChip(
                          label: Text(option.$2),
                          selected: distanceFilter == option.$1,
                          onSelected: (_) {
                            setState(() => distanceFilter = option.$1);
                            widget.controller.setDistanceFilter(option.$1);
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                ...trips.map(
                  (trip) {
                    final selected = _compare.contains(trip.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    trip.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bar_chart_rounded),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    selected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  tooltip: 'Add to compare',
                                  onPressed: () => _toggleCompare(trip),
                                ),
                                const AiInfoButton(),
                              ],
                            ),
                          Text(
                              '${trip.city} · ${trip.distanceKm.toStringAsFixed(0)} km · ${(trip.durationHours).toStringAsFixed(1)} h'),
                          const SizedBox(height: 8),
                          Text(trip.description),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.map_rounded),
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(AppRoutes.tripDetails, arguments: trip),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cloud delete will activate later.'),
                                    ),
                                  );
                                },
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(AppRoutes.tripDetails, arguments: trip),
                                child: const Text('Open'),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  },
                ),
                if (loadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
              ],
            ),
          );

    if (widget.embedded) {
      return list;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: list,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_compare.length >= 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton.extended(
                heroTag: 'compareTrips',
                onPressed: _openTripCompare,
                label: Text('Compare (${_compare.length})'),
                icon: const Icon(Icons.table_chart),
              ),
            ),
          FloatingActionButton.extended(
            heroTag: 'addTrip',
            onPressed: _addTrip,
            label: const Text('Add trip'),
            icon: const Icon(Icons.add_location_alt),
          ),
        ],
      ),
    );
  }

  Future<void> _addTrip() async {
    final title = TextEditingController();
    final city = TextEditingController();
    final distance = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Plan quick trip',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: city,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: distance,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Distance km'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final km = double.tryParse(distance.text) ?? 120;
                widget.controller.addTrip(
                  Trip(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title.text.isEmpty ? 'Custom trip' : title.text,
                    city: city.text.isEmpty ? 'Unknown' : city.text,
                    distanceKm: km,
                    date: DateTime.now().add(const Duration(days: 2)),
                    description: 'Added manually from quick planner.',
                    durationHours: 3.5,
                    chargingStops: const ['City Center Plaza'],
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  void _toggleCompare(Trip trip) {
    setState(() {
      if (_compare.contains(trip.id)) {
        _compare.remove(trip.id);
      } else {
        if (_compare.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compare up to 3 trips at once.')),
          );
          return;
        }
        _compare.add(trip.id);
      }
    });
  }

  void _openTripCompare() {
    final entries = widget.controller.visibleTrips
        .where((trip) => _compare.contains(trip.id))
        .map(
          (trip) => CompareEntry(
            title: trip.title,
            stat:
                '${trip.city} · ${trip.distanceKm.toStringAsFixed(0)} km',
            range: '${trip.distanceKm.toStringAsFixed(0)} km total',
            power: '${trip.durationHours.toStringAsFixed(1)} h drive',
            chargeSpeed: trip.chargingStops.isNotEmpty
                ? '${trip.chargingStops.length} planned stops'
                : null,
            availability:
                'Arrival ${(trip.arrivalBattery * 100).round()}%',
          ),
        )
        .toList();
    Navigator.of(context).pushNamed(
      AppRoutes.compare,
      arguments: {'entries': entries, 'title': 'Trip compare'},
    );
  }
}
