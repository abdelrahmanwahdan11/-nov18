import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              children: const [
                Text('Adventure Trip - August',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Start: Munich · End: Innsbruck'),
                SizedBox(height: 8),
                Text('Total distance 380 km · 4h 10m drive'),
                SizedBox(height: 8),
                Text('Arrival range estimation 25%'),
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
