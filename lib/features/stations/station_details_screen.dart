import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Station details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.network(
              'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=1200&q=60',
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Downtown Supercharge',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('230 Green Ave, open 24/7'),
                SizedBox(height: 8),
                Text('Price 0.35 USD / kW · 6 connectors'),
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
