import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/skeleton_list.dart';

class EnergyOverviewScreen extends StatefulWidget {
  const EnergyOverviewScreen({super.key});

  @override
  State<EnergyOverviewScreen> createState() => _EnergyOverviewScreenState();
}

class _EnergyOverviewScreenState extends State<EnergyOverviewScreen> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (mounted) setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: SkeletonList(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Energy overview')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Charging speed'),
                SizedBox(height: 8),
                Text('Currently 87 kW · +52% today'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily summary'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      5,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 40 + index * 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary
                                .withOpacity(.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Charge limit'),
                Slider(
                  value: 0.75,
                  onChanged: (_) {},
                  divisions: 4,
                  label: '75%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
