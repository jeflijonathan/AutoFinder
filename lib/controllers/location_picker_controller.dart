// lib/controllers/location_picker_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:autofinder/services/location/location_service.dart';

class LocationPickerController extends ChangeNotifier {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  late double pickedLat;
  late double pickedLng;
  String pickedAddress = '';
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  bool isLoadingAddress = false;

  void initialize({
    required double initialLat,
    required double initialLng,
    required String initialAddress,
  }) {
    pickedLat = initialLat;
    pickedLng = initialLng;
    pickedAddress = initialAddress;
  }

  @override
  void dispose() {
    mapController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> reverseGeocode(double lat, double lng) async {
    isLoadingAddress = true;
    notifyListeners();

    final address = await LocationService.reverseGeocode(lat, lng);

    if (address != null) {
      pickedAddress = address;
    }

    isLoadingAddress = false;
    notifyListeners();
  }

  /// Mencari rekomendasi lokasi berdasarkan teks input
  Future<void> searchAddress(String query) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();

    final results = await LocationService.searchAddress(
      query: query,
      currentLat: pickedLat,
      currentLng: pickedLng,
    );

    searchResults = results;
    isSearching = false;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      pickedLat = position.latitude;
      pickedLng = position.longitude;
      searchResults = [];
      notifyListeners();

      mapController.move(LatLng(position.latitude, position.longitude), 16.0);
      await reverseGeocode(position.latitude, position.longitude);
    }
  }

  /// Menangani ketukan pada peta
  void onMapTap(TapPosition tapPosition, LatLng point) {
    pickedLat = point.latitude;
    pickedLng = point.longitude;
    searchResults = [];
    notifyListeners();

    reverseGeocode(point.latitude, point.longitude);
  }

  /// Menangani pemilihan hasil pencarian dari drop-down / list
  void selectSearchResult(Map<String, dynamic> result, BuildContext context) {
    final lat = double.parse(result['lat'].toString());
    final lng = double.parse(result['lon'].toString());
    final address = result['display_name'] as String;

    pickedLat = lat;
    pickedLng = lng;
    pickedAddress = address;
    searchController.text = address;
    searchResults = [];
    notifyListeners();

    mapController.move(LatLng(lat, lng), 16.0);
    FocusScope.of(context).unfocus();
  }

  /// Membersihkan kolom pencarian
  void clearSearch() {
    searchController.clear();
    searchResults = [];
    notifyListeners();
  }
}
