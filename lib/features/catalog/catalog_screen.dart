import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/catalog_controller.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/widgets/skeleton_list.dart';
import 'item_detail_overlay.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.controller});

  final CatalogController controller;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool loading = true;
  bool showOverlay = false;
  String? overlayImage;
  String category = 'All';
  String sortMode = 'Recommended';

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
    final items = widget.controller.itemsNotifier.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      floatingActionButton: widget.controller.selectedForCompare.length >= 2
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.compare),
              label: Text('Compare (${widget.controller.selectedForCompare.length})'),
              icon: const Icon(Icons.table_chart),
            )
          : null,
      body: loading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: SkeletonList(),
            )
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    AppSearchBar(
                      onChanged: widget.controller.search,
                      hintText: 'Search catalog',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Vehicles', 'Stations', 'Trips']
                          .map(
                            (label) => ChoiceChip(
                              label: Text(label),
                              selected: category == label,
                              onSelected: (_) {
                                setState(() => category = label);
                                widget.controller.toggleCategory(label);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: sortMode,
                      items: const [
                        DropdownMenuItem(value: 'Recommended', child: Text('Recommended')),
                        DropdownMenuItem(value: 'Range', child: Text('Highest range')),
                        DropdownMenuItem(value: 'Price', child: Text('Lowest price')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => sortMode = value);
                        widget.controller.changeSort(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {
                                  showOverlay = true;
                                  overlayImage = item.image;
                                }),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(item.image,
                                      height: 160, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              Text(item.description),
                              if (item.rangeKm != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Wrap(
                                    spacing: 12,
                                    children: [
                                      Text('Range ${item.rangeKm} km'),
                                      Text('Power ${item.power} hp'),
                                      Text('Charge ${item.chargeSpeed?.toStringAsFixed(0)} kW'),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(item.stat),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      widget.controller.selectedForCompare
                                              .contains(item)
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                    ),
                                    onPressed: () => setState(() {
                                      widget.controller.toggleSelection(item);
                                    }),
                                  ),
                                  const AiInfoButton(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showOverlay && overlayImage != null)
                  Positioned.fill(
                    child: ItemDetailOverlay(
                      image: overlayImage!,
                      onClose: () => setState(() => showOverlay = false),
                    ),
                  ),
              ],
            ),
    );
  }
}
