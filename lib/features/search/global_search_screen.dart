import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/catalog_controller.dart';
import '../../core/controllers/trips_controller.dart';
import '../../core/controllers/vehicle_controller.dart';
import '../../core/data/sample_stations.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/station.dart';
import '../../core/models/trip.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/filter_chip_widget.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({
    super.key,
    required this.vehicleController,
    required this.tripsController,
    required this.catalogController,
  });

  final VehicleController vehicleController;
  final TripsController tripsController;
  final CatalogController catalogController;

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _quickTerms = const ['Munich', 'BMW iX', 'Charging', 'Dubai'];
  String _category = 'all';
  String _query = '';
  late final List<Station> _stations;
  StreamSubscription<List<Trip>>? _tripSubscription;

  @override
  void initState() {
    super.initState();
    _stations = buildSampleStations();
    widget.vehicleController.addListener(_onSourcesChanged);
    widget.catalogController.addListener(_onSourcesChanged);
    widget.catalogController.itemsNotifier.addListener(_onSourcesChanged);
    _tripSubscription = widget.tripsController.tripsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  void _onSourcesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.vehicleController.removeListener(_onSourcesChanged);
    widget.catalogController.removeListener(_onSourcesChanged);
    widget.catalogController.itemsNotifier.removeListener(_onSourcesChanged);
    _tripSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  List<_SearchEntry> get _entries {
    final catalogItems = widget.catalogController.itemsNotifier.value.isNotEmpty
        ? widget.catalogController.itemsNotifier.value
        : widget.catalogController.allItems;
    final trips = widget.tripsController.visibleTrips.isNotEmpty
        ? widget.tripsController.visibleTrips
        : widget.tripsController.allTrips;
    final entries = <_SearchEntry>[];
    entries.addAll(
      widget.vehicleController.vehicles.map(
        (vehicle) => _SearchEntry(
          categoryKey: 'vehicles',
          title: vehicle.name,
          subtitle: '${vehicle.range} km · ${vehicle.power} hp',
          image: vehicle.image,
          route: AppRoutes.home,
        ),
      ),
    );
    entries.addAll(
      trips.map(
        (trip) => _SearchEntry(
          categoryKey: 'trips',
          title: trip.title,
          subtitle: '${trip.city} · ${trip.distanceKm} km',
          route: AppRoutes.tripDetails,
          arguments: trip,
        ),
      ),
    );
    entries.addAll(
      _stations.map(
        (station) => _SearchEntry(
          categoryKey: 'stations',
          title: station.name,
          subtitle:
              '${station.city}, ${station.country} · ${station.price.toStringAsFixed(2)} /kW',
          image: station.image,
          route: AppRoutes.stationDetails,
          arguments: station,
        ),
      ),
    );
    entries.addAll(
      catalogItems.map(
        (item) => _SearchEntry(
          categoryKey: 'catalog',
          title: item.title,
          subtitle: item.stat,
          image: item.image,
          route: AppRoutes.catalog,
        ),
      ),
    );
    entries.sort((a, b) {
      if (a.categoryKey == b.categoryKey) {
        return a.title.compareTo(b.title);
      }
      return a.categoryKey.compareTo(b.categoryKey);
    });
    return entries;
  }

  List<_SearchEntry> get _filteredEntries {
    final lower = _query.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesCategory = _category == 'all' || entry.categoryKey == _category;
      final matchesQuery = lower.isEmpty ||
          entry.title.toLowerCase().contains(lower) ||
          entry.subtitle.toLowerCase().contains(lower);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _onSuggestionTap(String value) {
    setState(() {
      _query = value;
      _controller.text = value;
    });
  }

  void _openEntry(_SearchEntry entry) {
    Navigator.of(context).pushNamed(entry.route, arguments: entry.arguments);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final categories = ['all', 'vehicles', 'trips', 'stations', 'catalog'];
    final results = _filteredEntries;
    return Scaffold(
      appBar: AppBar(title: Text(locale.translate('globalSearch'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: locale.translate('searchEverything'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _query = '';
                            _controller.clear();
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map(
                      (key) => FilterChipWidget(
                        label: locale.translate(key),
                        selected: _category == key,
                        onSelected: (_) => setState(() => _category = key),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              locale.translate('recentSearches'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _quickTerms
                  .map(
                    (term) => ActionChip(
                      label: Text(term),
                      onPressed: () => _onSuggestionTap(term),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('${locale.translate('results')} (${results.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: results.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          locale.translate('noResults'),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        key: ValueKey('${_category}_${_query}_${results.length}'),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) => _ResultTile(
                          entry: results[index],
                          onTap: _openEntry,
                        ),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: results.length,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.entry, required this.onTap});

  final _SearchEntry entry;
  final ValueChanged<_SearchEntry> onTap;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return AppCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(entry),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  entry.image ??
                      'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=500&q=60',
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(label: Text(locale.translate(entry.categoryKey))),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEntry {
  const _SearchEntry({
    required this.categoryKey,
    required this.title,
    required this.subtitle,
    required this.route,
    this.image,
    this.arguments,
  });

  final String categoryKey;
  final String title;
  final String subtitle;
  final String route;
  final String? image;
  final Object? arguments;
}
