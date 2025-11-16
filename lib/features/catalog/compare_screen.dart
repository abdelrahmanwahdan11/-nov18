import 'package:flutter/material.dart';

import '../../core/controllers/catalog_controller.dart';
import '../../core/models/compare_entry.dart';
import '../../core/widgets/app_card.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({
    super.key,
    this.controller,
    this.entries,
    this.title = 'Compare',
  });

  final CatalogController? controller;
  final List<CompareEntry>? entries;
  final String title;

  List<CompareEntry> _resolveEntries() {
    if (entries != null) return entries!;
    if (controller == null) return [];
    return controller!.selectedForCompare
        .map(
          (item) => CompareEntry(
            title: item.title,
            stat: item.stat,
            range: item.rangeKm != null ? '${item.rangeKm} km' : null,
            power: item.power != null ? '${item.power} hp' : null,
            chargeSpeed:
                item.chargeSpeed != null ? '${item.chargeSpeed!.toStringAsFixed(0)} kW' : null,
            price: item.price != null ? 'USD ${item.price!.toStringAsFixed(0)}' : null,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final compareEntries = _resolveEntries();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: compareEntries.isEmpty
          ? const Center(child: Text('Select items to compare from any list.'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: AppCard(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    columnWidths: const {
                      0: FixedColumnWidth(130),
                    },
                    children: [
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Property',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ...compareEntries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                entry.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ..._buildRows(compareEntries),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  List<TableRow> _buildRows(List<CompareEntry> compareEntries) {
    final extractors = <String, String? Function(CompareEntry)>{
      'Stat': (entry) => entry.stat,
      'Range': (entry) => entry.range,
      'Power': (entry) => entry.power,
      'Charge speed': (entry) => entry.chargeSpeed,
      'Price': (entry) => entry.price,
      'Distance': (entry) => entry.distance,
      'Availability': (entry) => entry.availability,
    };

    return extractors.entries
        .where((entry) => compareEntries.any((item) => (entry.value(item) ?? '').isNotEmpty))
        .map(
          (extractor) => _row(
            extractor.key,
            compareEntries
                .map((entry) => extractor.value(entry)?.trim().isNotEmpty == true
                    ? extractor.value(entry)!
                    : '--')
                .toList(),
          ),
        )
        .toList();
  }

  TableRow _row(String label, List<String> values) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        ...values.map(
          (value) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(value, textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
