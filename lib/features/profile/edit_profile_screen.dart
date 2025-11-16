import 'package:flutter/material.dart';

import '../../core/widgets/primary_button.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Avatar URL')),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Save', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
