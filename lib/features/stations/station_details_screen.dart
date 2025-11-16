import 'package:flutter/material.dart';

import '../../core/models/station.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({super.key, this.station});

  final Station? station;

  @override
  Widget build(BuildContext context) {
    final details = station ??
        Station(
          id: 'details',
          name: 'Downtown Supercharge',
          city: 'Munich',
          country: 'Germany',
          price: 0.35,
          availability: '24/7',
          image:
              'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=1200&q=60',
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Station details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.network(details.image, height: 220, fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(details.name,
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${details.city}, ${details.country} · ${details.availability}'),
                const SizedBox(height: 8),
                Text('Price ${details.price.toStringAsFixed(2)} USD / kW · 6 connectors'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Book now', onPressed: () {}),
          const SizedBox(height: 8),
          SecondaryButton(label: 'Add to compare', onPressed: () {}),
        ],
      ),
    );
  }
}
