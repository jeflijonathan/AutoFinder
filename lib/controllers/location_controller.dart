import 'package:autofinder/services/location/location_service.dart';
import 'package:flutter/material.dart';

class LocationController extends ChangeNotifier {
  String _currentCity = "Jakarta";
  bool _isLoading = false;

  double? _latitude;
  double? _longitude;

  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;

  double? get latitude => _latitude;
  double? get longitude => _longitude;

  Future<void> fetchUserLocation() async {
    _isLoading = true;
    notifyListeners();

    final position = await LocationService.getCurrentPosition();

    if (position != null) {
      _latitude = position.latitude;
      _longitude = position.longitude;
    }

    _isLoading = false;
    notifyListeners();
  }
}
