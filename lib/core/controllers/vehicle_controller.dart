import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../storage/preferences_service.dart';

class VehicleController extends ChangeNotifier {
  VehicleController({PreferencesService? preferences})
      : _preferences = preferences ?? PreferencesService.instance,
        _vehicles = List.from(_seedVehicles) {
    _restoreGarage();
  }

  static const _garageKey = 'garage_vehicles';
  static const _selectedKey = 'garage_selected';

  static final List<Vehicle> _seedVehicles = [
    Vehicle(
      id: 'i4',
      name: 'BMW i4 M50',
      image:
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1000&q=60',
      range: 510,
      power: 536,
      speed: 225,
      batteryLevel: 0.72,
      drivetrain: 'AWD',
      efficiency: 16,
      odometer: 18200,
      healthScore: 94,
      batteryType: '80 kWh Li-ion',
      lastService: DateTime.now().subtract(const Duration(days: 46)),
    ),
    Vehicle(
      id: 'ix',
      name: 'BMW iX xDrive50',
      image:
          'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1000&q=60',
      range: 600,
      power: 610,
      speed: 235,
      batteryLevel: 0.45,
      drivetrain: 'AWD',
      efficiency: 19,
      odometer: 9500,
      healthScore: 88,
      batteryType: '111 kWh Li-ion',
      lastService: DateTime.now().subtract(const Duration(days: 72)),
    ),
  ];

  final PreferencesService _preferences;
  List<Vehicle> _vehicles;
  int _selectedIndex = 0;
  bool _loading = true;

  bool get loading => _loading;
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Vehicle> get favoriteVehicles =>
      List.unmodifiable(_vehicles.where((vehicle) => vehicle.isFavorite));
  Vehicle get currentVehicle => _vehicles[_selectedIndex];
  int get selectedIndex => _selectedIndex;
  double get batteryLevel => currentVehicle.batteryLevel;

  Future<void> _restoreGarage() async {
    final storedList = await _preferences.getStringList(_garageKey);
    if (storedList != null && storedList.isNotEmpty) {
      try {
        _vehicles = storedList
            .map((entry) => Vehicle.fromMap(jsonDecode(entry)))
            .toList();
      } catch (_) {
        _vehicles = List.from(_seedVehicles);
      }
    }
    final savedIndex =
        await _preferences.getInt(_selectedKey, defaultValue: 0);
    if (savedIndex < _vehicles.length) {
      _selectedIndex = savedIndex;
    } else {
      _selectedIndex = 0;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _persistGarage() async {
    await _preferences.setStringList(
      _garageKey,
      _vehicles.map((vehicle) => jsonEncode(vehicle.toMap())).toList(),
    );
    await _preferences.setInt(_selectedKey, _selectedIndex);
  }

  void selectVehicle(int index) {
    if (index < 0 || index >= _vehicles.length) return;
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    _persistGarage();
    notifyListeners();
  }

  void markPrimary(String id) {
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == id);
    if (index == -1) return;
    selectVehicle(index);
  }

  void setBatteryLevel(double value) {
    final level = value.clamp(0, 1).toDouble();
    _vehicles[_selectedIndex] =
        currentVehicle.copyWith(batteryLevel: level);
    _persistGarage();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == id);
    if (index == -1) return;
    final vehicle = _vehicles[index];
    _vehicles[index] = vehicle.copyWith(isFavorite: !vehicle.isFavorite);
    _persistGarage();
    notifyListeners();
  }

  void updateVehicle(
    String id, {
    int? range,
    int? power,
    int? speed,
    int? odometer,
    int? efficiency,
    double? batteryLevel,
    String? drivetrain,
    int? healthScore,
    DateTime? lastService,
    String? batteryType,
  }) {
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == id);
    if (index == -1) return;
    var vehicle = _vehicles[index];
    vehicle = vehicle.copyWith(
      range: range,
      power: power,
      speed: speed,
      odometer: odometer,
      efficiency: efficiency,
      batteryLevel: batteryLevel?.clamp(0, 1).toDouble(),
      drivetrain: drivetrain,
      healthScore: healthScore,
      lastService: lastService,
      batteryType: batteryType,
    );
    _vehicles[index] = vehicle;
    _persistGarage();
    notifyListeners();
  }

  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    _selectedIndex = _vehicles.length - 1;
    _persistGarage();
    notifyListeners();
  }

  void removeVehicle(String id) {
    if (_vehicles.length == 1) return;
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == id);
    if (index == -1) return;
    _vehicles.removeAt(index);
    if (_selectedIndex >= _vehicles.length) {
      _selectedIndex = _vehicles.length - 1;
    }
    _persistGarage();
    notifyListeners();
  }
}
