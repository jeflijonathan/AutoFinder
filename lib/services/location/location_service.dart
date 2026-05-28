import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static const String _userAgent = 'AutoFinder/1.0';

  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  static Future<String?> getCurrentCity() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return null;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ?? place.subAdministrativeArea;
      }
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }

    return null;
  }

  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String formattedAddress = data['display_name'] ?? '';

        if (data['address'] != null) {
          final address = data['address'];
          final road =
              address['road'] ??
              address['pedestrian'] ??
              address['path'] ??
              address['street'];
          final neighbourhood =
              address['neighbourhood'] ??
              address['village'] ??
              address['suburb'];
          final city =
              address['city'] ?? address['town'] ?? address['municipality'];

          List<String> parts = [];
          if (road != null) parts.add(road);
          if (neighbourhood != null) parts.add(neighbourhood);
          if (city != null) parts.add(city);

          if (parts.isNotEmpty) {
            final state = address['state'] ?? '';
            if (state.isNotEmpty) parts.add(state);
            formattedAddress = parts.join(', ');
          }
        }
        return formattedAddress;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 4. Tambahan: Search Address (Teks Kueri -> Daftar Rekomendasi Lokasi)
  static Future<List<Map<String, dynamic>>> searchAddress({
    required String query,
    required double currentLat,
    required double currentLng,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      // Membuat bounding box (viewbox) berjarak radius sekitar posisi saat ini
      final double lngMin = currentLng - 0.2;
      final double latMax = currentLat + 0.2;
      final double lngMax = currentLng + 0.2;
      final double latMin = currentLat - 0.2;
      final String viewbox = '$lngMin,$latMax,$lngMax,$latMin';

      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&viewbox=$viewbox&bounded=0',
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
