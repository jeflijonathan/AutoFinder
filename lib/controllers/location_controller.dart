import 'package:flutter/material.dart';
import 'package:autofinder/services/location_service.dart';

class LocationController extends ChangeNotifier {
  String _currentCity = "Jakarta";
  bool _isLoading = false;

  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;

  Future<void> fetchUserLocation() async {
    _isLoading = true;
    notifyListeners();

    String? city = await LocationService.getCurrentCity();
    if (city != null && city.isNotEmpty) {
      _currentCity = city;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Jika user ingin mengubah lokasi secara manual (opsional)
  void setCity(String city) {
    _currentCity = city;
    notifyListeners();
  }
}
