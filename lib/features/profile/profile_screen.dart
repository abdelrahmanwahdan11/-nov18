import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/models/user.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.authController,
    this.embedded = false,
  });

  final AuthController authController;
  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, bool> _serviceToggles = {
    'smartCharging': true,
    'journeyBackup': true,
    'biometricUnlock': false,
  };

  final List<Map<String, String>> _activity = const [
    {
      'title': 'Synced with ConnectedDrive',
      'subtitle': 'All vehicle widgets refreshed 2 min ago',
    },
    {
      'title': 'Charging goal adjusted',
      'subtitle': 'Limit bumped to 85% for tonight',
    },
    {
      'title': 'Trip pack ready',
      'subtitle': 'Offline maps stored for Alpine Escape',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final user = widget.authController.user ?? AppUser.guest();
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _ProfileHeader(user: user, authController: widget.authController),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  _StatCard(
                      label: 'Driven',
                      value: '${user.totalDistanceKm.toStringAsFixed(0)} km'),
                  _StatCard(label: 'Trips', value: '${user.completedTrips}'),
                  _StatCard(
                    label: 'Eco score',
                    value: '${user.ecoScore.toStringAsFixed(0)}%',
                    accent: Theme.of(context).colorScheme.primary,
                  ),
                ];
                if (constraints.maxWidth < 520) {
                  return Column(
                    children: [
                      for (int i = 0; i < cards.length; i++) ...[
                        cards[i],
                        if (i != cards.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      Expanded(child: cards[i]),
                      if (i != cards.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Favorite stations',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      AiInfoButton(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (user.favoriteStations.isEmpty)
                    const Text('Bookmark stations to quickly plan charging stops.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.favoriteStations
                          .map((station) => Chip(label: Text(station)))
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Connected services',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('${_serviceToggles.values.where((e) => e).length}/3 active'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._serviceToggles.entries.map(
                    (entry) => SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_serviceLabel(entry.key)),
                      subtitle: Text(_serviceDescription(entry.key)),
                      value: entry.value,
                      onChanged: (value) => setState(() {
                        _serviceToggles[entry.key] = value;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Achievements',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.badges
                        .map((badge) => Chip(
                              label: Text(badge),
                              avatar: const Icon(Icons.emoji_events_rounded, size: 18),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Recent activity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.history_rounded),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._activity.map(
                    (item) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item['title']!),
                          subtitle: Text(item['subtitle']!),
                        ),
                        if (item != _activity.last) const Divider(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Personal Information'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Payment Methods'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Charging Account'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Edit profile',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Logout',
              onPressed: widget.authController.logout,
            ),
          ],
        );
      },
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: content,
    );
  }

  String _serviceLabel(String key) {
    switch (key) {
      case 'journeyBackup':
        return 'Offline journey backup';
      case 'biometricUnlock':
        return 'Biometric unlock';
      default:
        return 'Smart charging guard';
    }
  }

  String _serviceDescription(String key) {
    switch (key) {
      case 'journeyBackup':
        return 'Keep the next 3 trips cached for low-connectivity drives.';
      case 'biometricUnlock':
        return 'Use Face ID or fingerprint to protect remote controls.';
      default:
        return 'Pause charging automatically when tariffs peak.';
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.authController});

  final AppUser user;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(user.email),
        const SizedBox(height: 4),
        Text('${user.membershipLevel} member · since ${user.memberSince.year}'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            Chip(
              avatar: const Icon(Icons.phone_rounded, size: 18),
              label: Text(user.phone),
            ),
            Chip(
              avatar: const Icon(Icons.verified_user_rounded, size: 18),
              label: Text(authController.isGuest ? 'Guest mode' : 'Secure login'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).textTheme.bodyLarge?.color;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
