import 'package:flutter/material.dart';

import '../../core/models/charging_session.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/skeleton_list.dart';

class EnergyOverviewScreen extends StatefulWidget {
  const EnergyOverviewScreen({super.key});

  @override
  State<EnergyOverviewScreen> createState() => _EnergyOverviewScreenState();
}

class _EnergyOverviewScreenState extends State<EnergyOverviewScreen> {
  bool loading = true;
  EnergyRange range = EnergyRange.week;
  double limit = 0.75;
  bool autoTarget = true;
  late final List<ChargingSession> _sessions;

  List<double> get _dataSet {
    switch (range) {
      case EnergyRange.month:
        return const [54, 68, 60, 52, 74, 80, 64, 90];
      case EnergyRange.year:
        return const [520, 480, 610, 590, 640, 700, 720, 680, 650, 600, 560, 580];
      case EnergyRange.week:
      default:
        return const [24, 32, 18, 20, 34, 40, 28];
    }
  }

  @override
  void initState() {
    super.initState();
    _sessions = [
      ChargingSession(
        id: 'energy-1',
        station: 'Home Wallbox',
        startTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        energyKwh: 42,
        cost: 11.2,
        status: ChargingStatus.completed,
      ),
      ChargingSession(
        id: 'energy-2',
        station: 'City Hub',
        startTime: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        endTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        energyKwh: 33,
        cost: 12.7,
        status: ChargingStatus.completed,
      ),
    ];
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
              children: [
                Row(
                  children: const [
                    Text('Charging speed'),
                    SizedBox(width: 8),
                    AiInfoButton(),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Currently 87 kW · +52% today'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: EnergyRange.values
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item.label),
                          selected: range == item,
                          onSelected: (_) => setState(() => range = item),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Summary charge (kWh)'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _dataSet
                        .map(
                          (value) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 20 + value,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(.15),
                                    Theme.of(context).colorScheme.primary,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
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
                  value: limit,
                  onChanged: (value) => setState(() => limit = value),
                  divisions: 4,
                  label: '${(limit * 100).round()}%',
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: autoTarget,
                  onChanged: (value) => setState(() => autoTarget = value),
                  title: const Text('Auto target mode'),
                  subtitle: const Text('Learns from trips to adjust the slider automatically.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent sessions'),
                const SizedBox(height: 12),
                ..._sessions.map(
                  (session) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.ev_station),
                    title: Text(session.station),
                    subtitle: Text(
                        '${session.energyKwh} kWh · ${session.cost.toStringAsFixed(2)} USD'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openSession(session),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _MixRow(label: 'Grid energy', value: 0.55, color: Colors.blueGrey),
                SizedBox(height: 12),
                _MixRow(label: 'Solar offset', value: 0.3, color: Colors.orange),
                SizedBox(height: 12),
                _MixRow(label: 'Regenerative', value: 0.15, color: Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Export local report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reports export locally until cloud sync is available.'),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  void _openSession(ChargingSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.station),
        content: Text(
            'Energy ${session.energyKwh} kWh · Duration ${session.duration.inMinutes} min.'
            ' Detailed telemetry will sync later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }
}

enum EnergyRange { week, month, year }

extension on EnergyRange {
  String get label {
    switch (this) {
      case EnergyRange.week:
        return 'Week';
      case EnergyRange.month:
        return 'Month';
      case EnergyRange.year:
        return 'Year';
    }
  }
}

class _MixRow extends StatelessWidget {
  const _MixRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: color.withOpacity(.2),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
    );
  }
}
