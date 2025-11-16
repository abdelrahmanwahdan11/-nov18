import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/models/station.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/filter_chip_widget.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/widgets/skeleton_list.dart';

class StationsListScreen extends StatefulWidget {
  const StationsListScreen({super.key, required this.appController});

  final AppController appController;

  @override
  State<StationsListScreen> createState() => _StationsListScreenState();
}

class _StationsListScreenState extends State<StationsListScreen> {
  bool loading = true;
  bool loadingMore = false;
  String priceFilter = 'All';
  String availabilityFilter = 'Any';
  String query = '';
  final List<Station> _allStations = [];
  List<Station> _visible = [];
  final Set<String> _compare = {};
  final ScrollController _scrollController = ScrollController();
  int page = 1;
  final int pageSize = 4;

  @override
  void initState() {
    super.initState();
    _generateStations();
    _scrollController.addListener(_onScroll);
    Future.delayed(const Duration(milliseconds: 800)).then((_) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _generateStations() {
    final images = [
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=60',
      'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=900&q=60',
      'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=900&q=60',
    ];
    for (var i = 0; i < 12; i++) {
      _allStations.add(
        Station(
          id: 'station-$i',
          name: 'Green Hub ${i + 1}',
          city: i.isEven ? 'Munich' : 'Abu Dhabi',
          country: i.isEven ? 'Germany' : 'UAE',
          price: 0.25 + i * 0.02,
          availability: i % 3 == 0 ? 'Now' : '24/7',
          image: images[i % images.length],
        ),
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || loadingMore) return;
    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent - 120 &&
        _visible.length < _filteredList.length) {
      setState(() => loadingMore = true);
      Future.delayed(const Duration(milliseconds: 400)).then((_) {
        page++;
        _applyFilters(resetPage: false);
        if (mounted) {
          setState(() => loadingMore = false);
        }
      });
    }
  }

  List<Station> get _filteredList {
    Iterable<Station> list = _allStations;
    if (query.isNotEmpty) {
      list = list.where((station) =>
          station.name.toLowerCase().contains(query.toLowerCase()) ||
          station.city.toLowerCase().contains(query.toLowerCase()) ||
          station.country.toLowerCase().contains(query.toLowerCase()));
    }
    if (priceFilter == 'Budget') {
      list = list.where((station) => station.price < 0.35);
    } else if (priceFilter == 'Premium') {
      list = list.where((station) => station.price >= 0.35);
    }
    if (availabilityFilter != 'Any') {
      list = list.where((station) => station.availability == availabilityFilter);
    }
    return list.toList();
  }

  void _applyFilters({bool resetPage = true}) {
    if (resetPage) page = 1;
    final data = _filteredList;
    final takeCount = (page * pageSize).clamp(0, data.length);
    setState(() {
      _visible = data.take(takeCount).toList();
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _allStations.shuffle();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stations')),
      body: loading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: SkeletonList(),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  AppSearchBar(
                    onChanged: (value) {
                      query = value;
                      _applyFilters();
                    },
                    hintText: 'Search stations',
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipWidget(
                          label: 'All',
                          selected: priceFilter == 'All',
                          onSelected: (_) {
                            priceFilter = 'All';
                            _applyFilters();
                          },
                        ),
                        FilterChipWidget(
                          label: 'Budget',
                          selected: priceFilter == 'Budget',
                          onSelected: (_) {
                            priceFilter = 'Budget';
                            _applyFilters();
                          },
                        ),
                        FilterChipWidget(
                          label: 'Premium',
                          selected: priceFilter == 'Premium',
                          onSelected: (_) {
                            priceFilter = 'Premium';
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['Any', 'Now', '24/7']
                        .map(
                          (label) => FilterChip(
                            label: Text('Availability $label'),
                            selected: availabilityFilter == label,
                            onSelected: (_) {
                              setState(() => availabilityFilter = label);
                              _applyFilters();
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  ..._visible.map(_StationCard),
                  if (loadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_compare.length >= 2)
                    AppCard(
                      child: Row(
                        children: [
                          Text('Ready to compare ${_compare.length} stations'),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Comparison coming soon'),
                                  content: const Text(
                                      'The selected stations will sync with the general compare table in the next drop.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    )
                                  ],
                                ),
                              );
                            },
                            child: const Text('View summary'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _StationCard(Station station) {
    final format = widget.appController.formatDistance(12 + station.price * 30);
    final inCompare = _compare.contains(station.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(station.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${station.city}, ${station.country}'),
              trailing: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => Navigator.of(context)
                    .pushNamed(AppRoutes.stationDetails, arguments: station),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(station.image, height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Price ${station.price.toStringAsFixed(2)} USD/kW'),
                const Spacer(),
                Text('Distance $format'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(station.availability)),
                const Spacer(),
                const AiInfoButton(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Book now',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (inCompare) {
                        _compare.remove(station.id);
                      } else {
                        _compare.add(station.id);
                      }
                    });
                  },
                  icon: Icon(inCompare ? Icons.check : Icons.add),
                  label: Text(inCompare ? 'Added' : 'Add to compare'),
                )
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=60',
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
