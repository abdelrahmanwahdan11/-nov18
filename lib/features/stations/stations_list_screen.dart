import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/catalog_controller.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/filter_chip_widget.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/widgets/skeleton_list.dart';

class StationsListScreen extends StatefulWidget {
  const StationsListScreen({super.key, required this.controller});

  final CatalogController controller;

  @override
  State<StationsListScreen> createState() => _StationsListScreenState();
}

class _StationsListScreenState extends State<StationsListScreen> {
  bool loading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    widget.controller.itemsNotifier.addListener(_update);
    widget.controller.load().then((_) => setState(() => loading = false));
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    widget.controller.itemsNotifier.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = widget.controller.itemsNotifier.value;
    final items = selectedFilter == 'All'
        ? allItems
        : allItems.where((item) => item.category == selectedFilter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Stations')),
      body: loading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: SkeletonList(),
            )
          : RefreshIndicator(
              onRefresh: widget.controller.load,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  AppSearchBar(
                    onChanged: widget.controller.search,
                    hintText: 'Search stations',
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipWidget(
                          label: 'All',
                          selected: selectedFilter == 'All',
                          onSelected: (_) {
                            setState(() => selectedFilter = 'All');
                            widget.controller.toggleCategory('All');
                          },
                        ),
                        FilterChipWidget(
                          label: 'Vehicles',
                          selected: selectedFilter == 'Vehicles',
                          onSelected: (_) {
                            setState(() => selectedFilter = 'Vehicles');
                            widget.controller.toggleCategory('Vehicles');
                          },
                        ),
                        FilterChipWidget(
                          label: 'Stations',
                          selected: selectedFilter == 'Stations',
                          onSelected: (_) {
                            setState(() => selectedFilter = 'Stations');
                            widget.controller.toggleCategory('Stations');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.title),
                              subtitle: Text(item.description),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.stationDetails),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                item.image,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.stat),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Book now'),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
