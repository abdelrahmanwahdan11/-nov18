import 'package:flutter/material.dart';

import '../../core/models/trip.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

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
          segments: const [
            TripSegment(
              label: 'Departure',
              location: 'Munich HQ',
              distanceKm: 0,
              driveDuration: Duration.zero,
              note: 'Cabin preconditioned',
            ),
            TripSegment(
              label: 'Charging stop',
              location: 'Ionity Hub',
              distanceKm: 210,
              driveDuration: Duration(hours: 2, minutes: 5),
              stopType: TripStopType.charging,
              note: '35 min pause',
            ),
            TripSegment(
              label: 'Arrival',
              location: 'Innsbruck',
              distanceKm: 170,
              driveDuration: Duration(hours: 1, minutes: 50),
              stopType: TripStopType.arrival,
              note: 'Valet charging reserved',
            ),
          ],
          highlights: const ['Scenic Alpine mode', 'Smart cruise engaged'],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(details.title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(details.description),
                        ],
                      ),
                    ),
                    AiInfoButton(
                      onPressed: () => _showAi(context, details),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatChip(
                      label: 'Distance',
                      value: '${details.distanceKm.toStringAsFixed(0)} km',
                      icon: Icons.route,
                    ),
                    _StatChip(
                      label: 'Drive',
                      value: '${details.durationHours.toStringAsFixed(1)} h',
                      icon: Icons.timelapse,
                    ),
                    _StatChip(
                      label: 'Arrival',
                      value: '${(details.arrivalBattery * 100).round()}%',
                      icon: Icons.battery_charging_full,
                    ),
                    _StatChip(
                      label: 'Consumption',
                      value: '${details.estimatedConsumption.toStringAsFixed(1)} kWh/100km',
                      icon: Icons.energy_savings_leaf,
                    ),
                  ],
                ),
                if (details.highlights.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Highlights',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: details.highlights
                        .map((highlight) => Chip(
                              avatar: const Icon(Icons.auto_awesome, size: 16),
                              label: Text(highlight),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Itinerary',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...() {
                  final timeline = _timeline(details);
                  return timeline
                      .asMap()
                      .entries
                      .map(
                        (entry) => _SegmentTile(
                          segment: entry.value,
                          isLast: entry.key == timeline.length - 1,
                        ),
                      )
                      .toList();
                }(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weather & terrain',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(details.weatherSummary),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=900&q=60',
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.terrain_outlined),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Elevation changes are synced to adaptive suspension.'),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Download offline pack',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Offline navigation package will be ready soon.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<TripSegment> _timeline(Trip trip) {
    if (trip.segments.isNotEmpty) {
      return trip.segments;
    }
    return [
      TripSegment(
        label: 'Departure',
        location: trip.city,
        distanceKm: 0,
        driveDuration: Duration.zero,
      ),
      ...trip.chargingStops.map(
        (stop) => TripSegment(
          label: 'Charging stop',
          location: stop,
          distanceKm: trip.distanceKm / (trip.chargingStops.length + 1),
          driveDuration: const Duration(hours: 1, minutes: 20),
          stopType: TripStopType.charging,
        ),
      ),
      TripSegment(
        label: 'Arrival',
        location: 'Destination',
        distanceKm: trip.distanceKm,
        driveDuration: Duration(hours: trip.durationHours.round()),
        stopType: TripStopType.arrival,
      ),
    ];
  }

  void _showAi(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI insights',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(
              'Expect ${(trip.estimatedConsumption).toStringAsFixed(1)} kWh/100km thanks to regen braking. '
              'Charging stops already include lounge reservations.',
            ),
            const SizedBox(height: 12),
            const Text('Cloud sync is disabled in this offline build.'),
          ],
        ),
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({required this.segment, required this.isLast});

  final TripSegment segment;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = segment.stopType == TripStopType.charging
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: color.withOpacity(.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(segment.label,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(segment.location),
                const SizedBox(height: 4),
                Text(
                  '${segment.distanceKm.toStringAsFixed(0)} km · ${segment.driveDuration.inMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (segment.note != null) ...[
                  const SizedBox(height: 4),
                  Text(segment.note!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
