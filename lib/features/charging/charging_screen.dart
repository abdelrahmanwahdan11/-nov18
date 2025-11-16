import 'package:flutter/material.dart';

import '../../core/models/charging_session.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class ChargingScreen extends StatefulWidget {
  const ChargingScreen({super.key});

  @override
  State<ChargingScreen> createState() => _ChargingScreenState();
}

class _ChargingScreenState extends State<ChargingScreen> {
  bool limit = true;
  double slider = 80;
  bool smartSchedule = true;
  bool solarBoost = false;
  String section = 'Overview';
  late final List<ChargingSession> sessions;
  late final List<ChargingSchedule> schedules;

  @override
  void initState() {
    super.initState();
    sessions = [
      ChargingSession(
        id: 'now',
        station: 'Home Wallbox',
        startTime: DateTime.now().subtract(const Duration(minutes: 25)),
        endTime: DateTime.now().add(const Duration(minutes: 20)),
        energyKwh: 37,
        cost: 10.4,
        status: ChargingStatus.running,
      ),
      ChargingSession(
        id: 'prev-1',
        station: 'BMW Lounge',
        startTime: DateTime.now().subtract(const Duration(hours: 10)),
        endTime: DateTime.now().subtract(const Duration(hours: 9, minutes: 10)),
        energyKwh: 52,
        cost: 18.2,
        status: ChargingStatus.completed,
      ),
      ChargingSession(
        id: 'prev-2',
        station: 'Ionity Hub',
        startTime: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 3, minutes: 5)),
        energyKwh: 44,
        cost: 14.1,
        status: ChargingStatus.completed,
      ),
    ];
    schedules = [
      ChargingSchedule(
        title: 'Weekday commute',
        window: '22:00 - 06:00',
        limit: 85,
      ),
      ChargingSchedule(
        title: 'Road trip prep',
        window: 'Saturday · 08:00 - 10:00',
        limit: 100,
        autoStart: false,
      ),
    ];
  }

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
              children: [
                Row(
                  children: const [
                    Text('Time to full charge'),
                    SizedBox(width: 8),
                    AiInfoButton(),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('45 min · 78% battery'),
                const SizedBox(height: 12),
                const Text('Estimated range 520 km'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.flash_on, size: 18),
                      label: const Text('AC · 11 kW'),
                    ),
                    Chip(
                      avatar: const Icon(Icons.eco_outlined, size: 18),
                      label: Text(solarBoost ? 'Solar boost on' : 'Solar boost off'),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cost per kW'),
                const SizedBox(height: 8),
                const Text('USD 0.32'),
                const SizedBox(height: 8),
                const Text('Port type CCS Combo'),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: solarBoost,
                  onChanged: (value) => setState(() => solarBoost = value),
                  title: const Text('Prioritize solar energy window'),
                  subtitle: const Text('Keeps charging paused until rooftop surplus is detected.'),
                )
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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: smartSchedule,
                  title: const Text('Smart departure schedule'),
                  subtitle: const Text('Aligns charge completion with your calendar events.'),
                  onChanged: (value) => setState(() => smartSchedule = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Overview', 'History', 'Schedule']
                .map(
                  (label) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: section == label,
                      onSelected: (_) => setState(() => section = label),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Builder(
              key: ValueKey(section),
              builder: (context) {
                if (section == 'History') {
                  return Column(
                    children: sessions
                        .map((session) => _SessionTile(
                              session: session,
                              onTap: () => _showSession(session),
                            ))
                        .toList(),
                  );
                }
                if (section == 'Schedule') {
                  return Column(
                    children: [
                      ...schedules.map(
                        (schedule) => _ScheduleTile(schedule: schedule),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Plan new schedule',
                        onPressed: _planSchedule,
                      )
                    ],
                  );
                }
                return Column(
                  children: const [
                    _InsightTile(
                      title: 'Battery care',
                      subtitle:
                          'Charging pauses at 85% for daily drives and resumes before road trips.',
                      icon: Icons.favorite_outline,
                    ),
                    SizedBox(height: 12),
                    _InsightTile(
                      title: 'Grid friendly',
                      subtitle:
                          'Smart schedule shifts load to cheaper slots — estimated savings USD 18/mo.',
                      icon: Icons.savings_outlined,
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showSession(ChargingSession session) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.station,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Energy ${session.energyKwh} kWh · ${session.cost.toStringAsFixed(2)} USD'),
            const SizedBox(height: 12),
            Text(
                'Duration ${session.duration.inMinutes} min • Status ${session.status.name}'),
            const SizedBox(height: 12),
            const Text('Detailed analytics will sync when cloud telemetry arrives.'),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _planSchedule() async {
    final name = TextEditingController();
    final limitController = TextEditingController(text: '90');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create offline schedule',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Charge limit %'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Save locally',
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Schedule "${name.text.isEmpty ? 'Unnamed schedule' : name.text}" stored offline.'),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.onTap});

  final ChargingSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            session.status == ChargingStatus.running
                ? Icons.bolt
                : Icons.history,
          ),
          title: Text(session.station),
          subtitle: Text(
              '${session.energyKwh.toStringAsFixed(0)} kWh · ${session.cost.toStringAsFixed(2)} USD'),
          trailing: Text(session.status.name.toUpperCase()),
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.schedule});

  final ChargingSchedule schedule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: ListTile(
          leading: const Icon(Icons.schedule_rounded),
          title: Text(schedule.title),
          subtitle: Text('${schedule.window} · Limit ${schedule.limit}%'),
          trailing: Switch(
            value: schedule.autoStart,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Auto-start toggle is stored locally for now.'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
