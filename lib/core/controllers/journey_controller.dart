import 'dart:math';

import 'package:flutter/material.dart';

import '../models/journey_plan.dart';

class JourneyController extends ChangeNotifier {
  JourneyController() {
    final now = DateTime.now();
    _plans = [
      JourneyPlan(
        id: 'journey-1',
        title: 'Desert energy cruise',
        origin: 'Riyadh HQ',
        destination: 'NEOM Oasis',
        distanceKm: 1180,
        durationHours: 11.5,
        stops: const ['Qassim Hub', 'Hail Ultra-fast', 'Tabuk Oasis'],
        bufferPercent: 18,
        chargeLimit: 85,
        weather: 'Sunny • 28°C',
        energyCost: 214,
        departure: now.add(const Duration(hours: 8)),
        mapImage:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=60',
        aiNote:
            'AI will soon recommend better cross-wind legs and shared charging reservations here.',
        focus: 'eco',
      ),
      JourneyPlan(
        id: 'journey-2',
        title: 'Coastal breeze sprint',
        origin: 'Jeddah Corniche',
        destination: 'Jazan Riviera',
        distanceKm: 710,
        durationHours: 6.2,
        stops: const ['Lithium Bay', 'Farasan Preview'],
        bufferPercent: 12,
        chargeLimit: 90,
        weather: 'Humid • 32°C',
        energyCost: 138,
        departure: now.add(const Duration(days: 1, hours: 2)),
        mapImage:
            'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=60',
        aiNote:
            'Soon the assistant will match tide-friendly rest stops with ultra-fast ports.',
        focus: 'express',
      ),
      JourneyPlan(
        id: 'journey-3',
        title: 'Mountain vista escape',
        origin: 'Abha',
        destination: 'Al Baha Forest',
        distanceKm: 420,
        durationHours: 5.3,
        stops: const ['Sarawat Balcony', 'Cloud Park Terrace'],
        bufferPercent: 20,
        chargeLimit: 80,
        weather: 'Cool • 18°C',
        energyCost: 86,
        departure: now.add(const Duration(days: 2, hours: 5)),
        mapImage:
            'https://images.unsplash.com/photo-1470163395405-d2b80e7450ed?auto=format&fit=crop&w=1200&q=60',
        aiNote:
            'AI summaries will highlight regen-friendly descents and optimal viewpoints soon.',
        focus: 'scenic',
      ),
    ];
  }

  final Random _random = Random();
  late List<JourneyPlan> _plans;

  List<JourneyPlan> get plans {
    final sorted = [..._plans]..sort((a, b) => a.departure.compareTo(b.departure));
    return sorted;
  }

  JourneyPlan? get nextJourney {
    final now = DateTime.now().subtract(const Duration(hours: 1));
    try {
      return plans.firstWhere((plan) => plan.departure.isAfter(now));
    } catch (_) {
      return plans.isNotEmpty ? plans.first : null;
    }
  }

  List<JourneyPlan> featuredPlans([int count = 3]) {
    final list = plans;
    return list.take(count).toList();
  }

  void toggleFavorite(String id) {
    _plans = _plans
        .map((plan) =>
            plan.id == id ? plan.copyWith(isFavorite: !plan.isFavorite) : plan)
        .toList();
    notifyListeners();
  }

  JourneyPlan scheduleCustomPlan({
    required String origin,
    required String destination,
    required double bufferPercent,
    required double chargeLimit,
    required String focus,
    bool autoAdjustClimate = true,
  }) {
    final distance = 260 + _random.nextInt(620);
    final duration = (distance / 95).clamp(3, 15).toDouble();
    final departure = DateTime.now().add(
      Duration(hours: 6 + _random.nextInt(72)),
    );
    final plan = JourneyPlan(
      id: 'journey-${DateTime.now().millisecondsSinceEpoch}',
      title: _focusTitle(focus),
      origin: origin,
      destination: destination,
      distanceKm: distance.toDouble(),
      durationHours: double.parse(duration.toStringAsFixed(1)),
      stops: _buildStops(origin, destination),
      bufferPercent: bufferPercent,
      chargeLimit: chargeLimit,
      weather: _focusWeather(focus),
      energyCost: double.parse((distance * 0.18).toStringAsFixed(1)),
      departure: departure,
      mapImage: _mapImages[_random.nextInt(_mapImages.length)],
      aiNote: _aiNotes[_random.nextInt(_aiNotes.length)],
      focus: focus,
      autoAdjustClimate: autoAdjustClimate,
    );
    _plans = [plan, ..._plans];
    notifyListeners();
    return plan;
  }

  Future<void> refreshPlans() async {
    await Future.delayed(const Duration(milliseconds: 450));
    _plans = _plans
        .map(
          (plan) => plan.copyWith(
            bufferPercent: (plan.bufferPercent + _random.nextInt(3) - 1)
                .clamp(5, 25)
                .toDouble(),
            departure: plan.departure.add(Duration(hours: _random.nextInt(3))),
          ),
        )
        .toList();
    notifyListeners();
  }

  List<String> _buildStops(String origin, String destination) {
    final templates = [
      ['Desert Garden Hub', 'Solar Ridge Plaza'],
      ['Crystal Coast Supercharge', 'Heritage Valley Rest'],
      ['Skyline Balcony', 'Green Oasis 350kW'],
    ];
    final stops = templates[_random.nextInt(templates.length)];
    return [...stops, destination];
  }

  String _focusTitle(String focus) {
    switch (focus) {
      case 'express':
        return 'Express arrival route';
      case 'scenic':
        return 'Scenic discovery drive';
      default:
        return 'Efficient eco cruise';
    }
  }

  String _focusWeather(String focus) {
    switch (focus) {
      case 'express':
        return 'Clear • 30°C';
      case 'scenic':
        return 'Breezy • 22°C';
      default:
        return 'Mild • 26°C';
    }
  }

  static const List<String> _mapImages = [
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=60',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=60',
    'https://images.unsplash.com/photo-1470163395405-d2b80e7450ed?auto=format&fit=crop&w=1200&q=60',
    'https://images.unsplash.com/photo-1500534314210-042eeeddf899?auto=format&fit=crop&w=1200&q=60',
  ];

  static const List<String> _aiNotes = [
    'Future AI insights will balance charging queues with rest quality.',
    'Soon an assistant will stitch nearby attractions into the charging windows.',
    'AI summaries will recommend regen-friendly slopes for this plan.',
    'Next release unlocks cross-user convoy suggestions for this route.',
  ];
}
