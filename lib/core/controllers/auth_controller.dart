import 'package:flutter/material.dart';

import '../models/user.dart';
import '../storage/preferences_service.dart';

class AuthController extends ChangeNotifier {
  AuthController() {
    _restore();
  }

  AppUser? _user;
  bool _isGuest = false;

  AppUser? get user => _user;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => _user != null || _isGuest;

  Future<void> _restore() async {
    final prefs = PreferencesService.instance;
    final loggedIn = await prefs.getBool('loggedIn');
    final guest = await prefs.getBool('guest');

    if (loggedIn) {
      _user = AppUser(
        name: 'Lina EV',
        email: 'lina@evsmart.app',
        avatarUrl:
            'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=200&q=60',
      );
    }
    _isGuest = guest;
    notifyListeners();
  }

  Future<void> login(String email) async {
    _user = AppUser(
      name: 'Driver Pro',
      email: email,
      avatarUrl:
          'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=200&q=60',
    );
    _isGuest = false;
    await PreferencesService.instance.setBool('loggedIn', true);
    await PreferencesService.instance.setBool('guest', false);
    notifyListeners();
  }

  Future<void> loginAsGuest() async {
    _user = null;
    _isGuest = true;
    await PreferencesService.instance.setBool('guest', true);
    await PreferencesService.instance.setBool('loggedIn', false);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isGuest = false;
    await PreferencesService.instance.setBool('guest', false);
    await PreferencesService.instance.setBool('loggedIn', false);
    notifyListeners();
  }
}
