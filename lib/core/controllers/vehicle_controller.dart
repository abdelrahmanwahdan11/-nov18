import 'package:flutter/material.dart';

import '../models/vehicle.dart';

class VehicleController extends ChangeNotifier {
  VehicleController()
      : _vehicles = [
          Vehicle(
            id: 'i4',
            name: 'BMW i4 M50',
            image:
                'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=60',
            range: 510,
            power: 536,
            speed: 225,
            batteryLevel: 0.72,
          ),
          Vehicle(
            id: 'ix',
            name: 'BMW iX',
            image:
                'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=800&q=60',
            range: 600,
            power: 610,
            speed: 235,
            batteryLevel: 0.45,
          ),
        ];

  final List<Vehicle> _vehicles;
  int _selectedIndex = 0;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  Vehicle get currentVehicle => _vehicles[_selectedIndex];
  double get batteryLevel => currentVehicle.batteryLevel;

  void selectVehicle(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void setBatteryLevel(double value) {
    _vehicles[_selectedIndex] = Vehicle(
      id: currentVehicle.id,
      name: currentVehicle.name,
      image: currentVehicle.image,
      range: currentVehicle.range,
      power: currentVehicle.power,
      speed: currentVehicle.speed,
      batteryLevel: value,
    );
    notifyListeners();
  }
}
