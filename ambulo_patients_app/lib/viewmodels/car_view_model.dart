import 'package:flutter/material.dart';
import '../models/car_model.dart';

class CarViewModel extends ChangeNotifier {
  final List<Car> _cars = dummyCars;
  List<Car> get cars => _cars;

  Car? _selectedCar;
  Car? get selectedCar => _selectedCar;

  void selectCar(Car car) {
    _selectedCar = car;
    notifyListeners();
  }
}
