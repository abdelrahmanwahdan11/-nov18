import 'package:flutter/material.dart';

import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';

class ChargingScreen extends StatefulWidget {
  const ChargingScreen({super.key});

  @override
  State<ChargingScreen> createState() => _ChargingScreenState();
}

class _ChargingScreenState extends State<ChargingScreen> {
  bool limit = true;
  double slider = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charging')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Time to full charge'),
                SizedBox(height: 8),
                Text('45 min'),
                SizedBox(height: 12),
                Text('Estimated range 520 km'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Cost per kW'),
                SizedBox(height: 8),
                Text('USD 0.32'),
                SizedBox(height: 8),
                Text('Port type CCS Combo'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Advanced options',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const AiInfoButton(),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set charging limit'),
                  value: limit,
                  onChanged: (value) => setState(() => limit = value),
                ),
                Slider(
                  value: slider,
                  min: 50,
                  max: 100,
                  label: '${slider.round()}%',
                  onChanged: limit
                      ? (value) => setState(() => slider = value)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
