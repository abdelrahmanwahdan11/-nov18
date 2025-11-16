import 'dart:async';

import 'package:flutter/material.dart';

class CatalogItem {
  CatalogItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.stat,
    required this.image,
    this.price,
  });

  final String id;
  final String category;
  final String title;
  final String description;
  final String stat;
  final String image;
  final double? price;
}

class CatalogController extends ChangeNotifier {
  CatalogController() {
    _items = List.generate(
      10,
      (index) => CatalogItem(
        id: 'item-$index',
        category: index % 2 == 0 ? 'Vehicles' : 'Stations',
        title: 'Concept ${index + 1}',
        description: 'Efficient mobility item ${index + 1}.',
        stat: index % 2 == 0
            ? '${450 + index * 10} km range'
            : '${(0.29 + index * .02).toStringAsFixed(2)} USD / kW',
        image:
            'https://images.unsplash.com/photo-1517949908114-720226b864c1?auto=format&fit=crop&w=1000&q=60',
        price: 60000 + index * 1500,
      ),
    );
  }

  late List<CatalogItem> _items;
  final ValueNotifier<List<CatalogItem>> _listNotifier =
      ValueNotifier<List<CatalogItem>>([]);
  final List<CatalogItem> _selected = [];

  ValueNotifier<List<CatalogItem>> get itemsNotifier => _listNotifier;
  List<CatalogItem> get selectedForCompare => List.unmodifiable(_selected);

  Future<void> load() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _listNotifier.value = _items;
  }

  void search(String query) {
    final filtered = _items
        .where((item) =>
            item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _listNotifier.value = filtered;
  }

  void toggleCategory(String category) {
    if (category == 'All') {
      _listNotifier.value = _items;
    } else {
      _listNotifier.value =
          _items.where((item) => item.category == category).toList();
    }
  }

  void toggleSelection(CatalogItem item) {
    if (_selected.contains(item)) {
      _selected.remove(item);
    } else if (_selected.length < 3) {
      _selected.add(item);
    }
    notifyListeners();
  }

  void resetSelection() {
    _selected.clear();
    notifyListeners();
  }
}
