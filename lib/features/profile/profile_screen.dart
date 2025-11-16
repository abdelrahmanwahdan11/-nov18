import 'package:flutter/material.dart';

import '../../core/controllers/auth_controller.dart';
import '../../core/widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.authController, this.embedded = false});

  final AuthController authController;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final user = authController.user;
    final content = ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(user?.avatarUrl ??
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=200&q=60'),
        ),
        const SizedBox(height: 12),
        Text(user?.name ?? 'Guest', textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(user?.email ?? 'guest@evsmart.app', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ...['Personal Information', 'Payment Methods', 'Addresses', 'Charging Account', 'Vehicle Ownership']
            .map((item) => ListTile(
                  title: Text(item),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                )),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Logout', onPressed: authController.logout),
      ],
    );

    if (embedded) {
      return content;
    }

    return Scaffold(appBar: AppBar(title: const Text('Profile')), body: content);
  }
}
