import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      ('How do I sync my BMW EV?',
          'You can add vehicles from Settings → Vehicle Ownership to keep stats updated.'),
      ('Can I book public chargers?',
          'Yes, any "Book now" action in Stations will reserve a slot locally until backend integration ships.'),
      ('What about AI insights?',
          'AI powered summaries are mocked for now and will light up once data services are enabled.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Help & About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Need a hand?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('We collected the most common EV Smart Companion answers below.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map(
            (faq) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(faq.$1,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(faq.$2),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contact us',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.mail_outline),
                    SizedBox(width: 8),
                    Text('support@evsmart.app'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.chat_bubble_outline),
                    SizedBox(width: 8),
                    Text('+49 800 EV SMART'),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Send message',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Coming soon'),
                        content: const Text(
                            'Live chat and ticketing will be added in the connected release.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
