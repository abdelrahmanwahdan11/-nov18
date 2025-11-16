import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/controllers/auth_controller.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';

class QuickControlsScreen extends StatelessWidget {
  const QuickControlsScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'Energy',
        'Charging started 08:00 · Limit 80%',
        Icons.bolt,
      ),
      (
        'Climate',
        'Outside 24° · Glass locked',
        Icons.ac_unit,
      ),
      (
        'Media',
        'Electric Paradise playlist',
        Icons.music_note,
      ),
      (
        'Tire pressure',
        '2.5 · 2.4 · 2.6 · 2.5 bar',
        Icons.blur_circular,
      ),
      (
        'Location',
        'Last seen Downtown Hub',
        Icons.location_on,
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: .9,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return GestureDetector(
          onTap: () => _showDetails(context, card.$1),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(card.$3, color: Theme.of(context).colorScheme.primary),
                    const Spacer(),
                    const AiInfoButton(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Hey ${authController.user?.name ?? 'guest'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text(card.$1,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(card.$2),
                const Spacer(),
                if (card.$1 == 'Location')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=400&q=60',
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ).animate().fade().scale(begin: const Offset(.9, .9)),
        );
      },
    );
  }

  void _showDetails(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text('More controls and automation will arrive soon.'),
          ],
        ),
      ),
    );
  }
}
