import 'package:flutter/material.dart';

import '../../core/models/trip.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key, this.trip});

  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    final details = trip ??
        Trip(
          id: 'preview-trip',
          title: 'Adventure Trip - August',
          city: 'Munich',
          distanceKm: 380,
          date: DateTime.now(),
          description: 'Start: Munich · End: Innsbruck',
          durationHours: 4.1,
          arrivalBattery: 0.25,
          chargingStops: const ['Ionity Hub', 'Downtown Supercharge', 'Green Hills'],
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Trip details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.network(
              'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=60',
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(details.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const AiInfoButton(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(details.description),
                const SizedBox(height: 8),
                Text(
                  'Total ${details.distanceKm.toStringAsFixed(0)} km · ${details.durationHours.toStringAsFixed(1)} h drive',
                ),
                const SizedBox(height: 8),
                Text('Arrival range estimation ${(details.arrivalBattery * 100).round()}%'),
                const SizedBox(height: 12),
                Text('Charging stops',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...details.chargingStops.map(
                  (stop) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.ev_station),
                    title: Text(stop),
                    subtitle: const Text('Reserved slot · ETA synced'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Start trip', onPressed: () {}),
        ],
      ),
    );
  }
}
