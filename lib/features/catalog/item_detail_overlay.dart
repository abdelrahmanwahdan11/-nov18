import 'dart:math';

import 'package:flutter/material.dart';

class ItemDetailOverlay extends StatefulWidget {
  const ItemDetailOverlay({super.key, required this.image, required this.onClose});

  final String image;
  final VoidCallback onClose;

  @override
  State<ItemDetailOverlay> createState() => _ItemDetailOverlayState();
}

class _ItemDetailOverlayState extends State<ItemDetailOverlay> {
  bool flipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            final rotate = Tween(begin: pi, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              child: child,
              builder: (context, child) {
                final angle = flipped ? pi - rotate.value : rotate.value;
                return Transform(
                  transform: Matrix4.rotationY(angle),
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          child: flipped
              ? _OverlayBack(onTap: () => setState(() => flipped = false))
              : _OverlayFront(
                  image: widget.image,
                  onTap: () => setState(() => flipped = true),
                ),
        ),
      ),
    );
  }
}

class _OverlayFront extends StatelessWidget {
  const _OverlayFront({required this.image, required this.onTap});

  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(image, height: 300, fit: BoxFit.cover),
      ),
    );
  }
}

class _OverlayBack extends StatelessWidget {
  const _OverlayBack({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 300,
        width: 260,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('AI summary', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              'This vehicle will soon display AI-generated efficiency and sustainability metrics.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
