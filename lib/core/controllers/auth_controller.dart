import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../storage/preferences_service.dart';

class AuthController extends ChangeNotifier {
  AuthController() {
    _restore();
  }

  static const _userKey = 'profile_user';

  AppUser? _user;
  bool _isGuest = false;

  AppUser? get user => _user;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => _user != null || _isGuest;

  Future<void> _restore() async {
    final prefs = PreferencesService.instance;
    final loggedIn = await prefs.getBool('loggedIn');
    _isGuest = await prefs.getBool('guest');
    final stored = await prefs.getString(_userKey);

    if (stored != null) {
      _user = AppUser.fromJson(jsonDecode(stored) as Map<String, dynamic>);
    } else if (loggedIn) {
      _user = _seedUser('lina@evsmart.app');
      await _persistUser();
    }
    notifyListeners();
  }

  Future<void> login(String email) async {
    _user = _seedUser(email);
    _isGuest = false;
    await PreferencesService.instance.setBool('loggedIn', true);
    await PreferencesService.instance.setBool('guest', false);
    await _persistUser();
    notifyListeners();
  }

  Future<void> loginAsGuest() async {
    _user = null;
    _isGuest = true;
    await PreferencesService.instance.setBool('guest', true);
    await PreferencesService.instance.setBool('loggedIn', false);
    await PreferencesService.instance.remove(_userKey);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isGuest = false;
    await PreferencesService.instance.setBool('guest', false);
    await PreferencesService.instance.setBool('loggedIn', false);
    await PreferencesService.instance.remove(_userKey);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    double? totalDistanceKm,
    int? completedTrips,
  }) async {
    final baseUser = _user ?? _seedUser(email ?? 'guest@evsmart.app');
    _user = baseUser.copyWith(
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      totalDistanceKm: totalDistanceKm,
      completedTrips: completedTrips,
    );
    await _persistUser();
    notifyListeners();
  }

  AppUser _seedUser(String email) {
    return AppUser(
      name: 'Driver Pro',
      email: email,
      avatarUrl:
          'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=200&q=60',
      phone: '+971 50 123 4567',
      membershipLevel: 'Platinum',
      memberSince: DateTime(2021, 3, 12),
      totalDistanceKm: 18420,
      completedTrips: 126,
      ecoScore: 92,
      favoriteStations: const ['Ionity Munich', 'Dubai Marina Hub'],
      badges: const ['Efficient driver', 'Night explorer', 'Smart planner'],
    );
  }

  Future<void> _persistUser() async {
    if (_user == null) {
      await PreferencesService.instance.remove(_userKey);
      return;
    }
    final serialized = jsonEncode(_user!.toJson());
    await PreferencesService.instance.setString(_userKey, serialized);
  }
}
