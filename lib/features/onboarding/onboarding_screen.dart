import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/routes.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;
  Timer? _timer;
  int currentPage = 0;

  final slides = [
    (
      'Control your EV',
      'Monitor range, charging and smart controls in one tap.',
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=60'
    ),
    (
      'Plan effortless trips',
      'Trips automatically add verified charging stops.',
      'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=60'
    ),
    (
      'Stay maintained',
      'Maintenance reminders and AI assistants keep the ride smooth.',
      'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=60'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      currentPage = (currentPage + 1) % slides.length;
      _controller.animateToPage(
        currentPage,
        duration: 500.ms,
        curve: Curves.easeOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final welcomeMessage = widget.authController.isLoggedIn
        ? 'Welcome back'
        : 'Connect to your EV future';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  welcomeMessage,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => currentPage = value),
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(slide.$3, height: 240, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 32),
                        Text(slide.$1,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(
                          slide.$2,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: 300.ms,
                  width: currentPage == index ? 24 : 10,
                  height: 10,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PrimaryButton(
                    label: currentPage == slides.length - 1
                        ? 'Get started'
                        : 'Next',
                    onPressed: () {
                      if (currentPage == slides.length - 1) {
                        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                      } else {
                        _controller.nextPage(
                          duration: 400.ms,
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.login),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
