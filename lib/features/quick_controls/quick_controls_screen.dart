import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/controllers/auth_controller.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class QuickControlsScreen extends StatefulWidget {
  const QuickControlsScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<QuickControlsScreen> createState() => _QuickControlsScreenState();
}

class _QuickControlsScreenState extends State<QuickControlsScreen> {
  bool locked = true;
  bool glassLocked = true;
  bool mediaPlaying = false;
  double chargeLimit = 80;
  bool solarBoost = false;
  double cabinTemp = 21;
  bool rearDefrost = false;
  double mediaProgress = 0.35;

  @override
  Widget build(BuildContext context) {
    return GridView(
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
        childAspectRatio: .92,
      ),
      children: [
        _buildEnergyCard(context),
        _buildClimateCard(context),
        _buildMediaCard(context),
        _buildTireCard(context),
        _buildSecurityCard(context),
        _buildLocationCard(context),
      ]
          .map((card) => card.animate().fadeIn(duration: 300.ms).scale())
          .toList(),
    );
  }

  Widget _buildEnergyCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              const AiInfoButton(),
            ],
          ),
          const SizedBox(height: 8),
          Text('Energy',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Hi ${widget.authController.user?.name ?? 'guest'}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('Limit ${chargeLimit.round()}% · Solar ${solarBoost ? 'on' : 'off'}'),
          Slider(
            value: chargeLimit,
            min: 50,
            max: 100,
            divisions: 5,
            label: '${chargeLimit.round()}%',
            onChanged: (value) => setState(() => chargeLimit = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: solarBoost,
            title: const Text('Solar boost window'),
            onChanged: (value) => setState(() => solarBoost = value),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _showDetails('Energy automation'),
            child: const Text('Schedule charge'),
          )
        ],
      ),
    );
  }

  Widget _buildClimateCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.ac_unit, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              const AiInfoButton(),
            ],
          ),
          const SizedBox(height: 8),
          Text('Climate',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Cabin ${cabinTemp.toStringAsFixed(1)}° · Glass locked'),
          Slider(
            value: cabinTemp,
            min: 16,
            max: 26,
            label: '${cabinTemp.toStringAsFixed(1)}°',
            onChanged: (value) => setState(() => cabinTemp = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: rearDefrost,
            title: const Text('Rear defrost'),
            onChanged: (value) => setState(() => rearDefrost = value),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _showDetails('Climate routines'),
            child: const Text('Warm seats'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              IconButton(
                icon: Icon(
                  mediaPlaying ? Icons.pause_circle : Icons.play_circle,
                ),
                onPressed: () => setState(() => mediaPlaying = !mediaPlaying),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Media',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Electric Paradise · Episode 07'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: mediaProgress),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(mediaPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () => setState(() => mediaPlaying = !mediaPlaying),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {},
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTireCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.blur_circular,
                  color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              const AiInfoButton(),
            ],
          ),
          const SizedBox(height: 8),
          Text('Tire pressure',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: const [
              _TireChip(label: 'FL', value: '2.5 bar'),
              _TireChip(label: 'FR', value: '2.4 bar'),
              _TireChip(label: 'RL', value: '2.6 bar'),
              _TireChip(label: 'RR', value: '2.5 bar'),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _showDetails('Tire health'),
            child: const Text('View history'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_moon,
                  color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              const AiInfoButton(),
            ],
          ),
          const SizedBox(height: 8),
          Text('Security',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vehicle locked'),
            value: locked,
            onChanged: (value) => setState(() => locked = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Glass lock'),
            value: glassLocked,
            onChanged: (value) => setState(() => glassLocked = value),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Flash lights',
            onPressed: () => _showDetails('Security pulse'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on,
                  color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              const AiInfoButton(),
            ],
          ),
          const SizedBox(height: 8),
          Text('Location',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Downtown Hub · 3 min ago',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=500&q=60',
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _showDetails('Share live location'),
            child: const Text('Share ETA'),
          ),
        ],
      ),
    );
  }

  void _showDetails(String title) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Text(
                'Detailed automations will activate once cloud pairing is enabled.'),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Keep me posted',
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }
}

class _TireChip extends StatelessWidget {
  const _TireChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.primary.withOpacity(.08),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
