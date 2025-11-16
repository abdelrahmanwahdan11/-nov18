import 'package:flutter/material.dart';

import '../../core/controllers/catalog_controller.dart';
import '../../core/widgets/app_card.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key, required this.controller});

  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.selectedForCompare;
    return Scaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: items.isEmpty
          ? const Center(child: Text('Select items from catalog to compare.'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: AppCard(
                  child: Table(
            columnWidths: const {
              0: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                children: [
                  const Text('Property',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...items.map((e) => Text(e.title, textAlign: TextAlign.center)),
                ],
              ),
              _row('Stat', items.map((e) => e.stat).toList()),
              _row('Range',
                  items.map((e) => e.rangeKm?.toString() ?? '--').toList()),
              _row('Power',
                  items.map((e) => e.power?.toString() ?? '--').toList()),
              _row(
                'Charge speed',
                items.map((e) =>
                    e.chargeSpeed != null ? '${e.chargeSpeed!.toStringAsFixed(0)} kW' : '--').toList(),
              ),
              _row(
                'Price',
                items.map((e) => e.price?.toStringAsFixed(0) ?? '--').toList(),
              ),
            ],
          )),
            ),
    );
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
