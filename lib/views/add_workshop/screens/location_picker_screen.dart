import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:autofinder/services/location_service.dart';

class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String initialAddress;

  const LocationPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.initialAddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController _mapController;
  late double _pickedLat;
  late double _pickedLng;
  String _pickedAddress = '';

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pickedLat = widget.initialLat;
    _pickedLng = widget.initialLng;
    _pickedAddress = widget.initialAddress;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => _isLoadingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'User-Agent': 'AutoFinder/1.0'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String formattedAddress = data['display_name'] ?? '';

        // Try to build a better address prioritizing street name
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

        setState(() {
          _pickedAddress = formattedAddress;
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  // Geocoding search: nama jalan → koordinat
  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      // Create a bounding box around the current location to prioritize local results
      final double lngMin = _pickedLng - 0.2; // approx 22km
      final double latMax = _pickedLat + 0.2;
      final double lngMax = _pickedLng + 0.2;
      final double latMin = _pickedLat - 0.2;
      final String viewbox = '$lngMin,$latMax,$lngMax,$latMin';

      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&viewbox=$viewbox&bounded=0',
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'User-Agent': 'AutoFinder/1.0'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _searchResults = data.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (_) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      setState(() {
        _pickedLat = position.latitude;
        _pickedLng = position.longitude;
        _searchResults = [];
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 16.0);
      _reverseGeocode(position.latitude, position.longitude);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _pickedLat = point.latitude;
      _pickedLng = point.longitude;
      _searchResults = [];
    });
    _reverseGeocode(point.latitude, point.longitude);
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = double.parse(result['lat'].toString());
    final lng = double.parse(result['lon'].toString());
    final address = result['display_name'] as String;

    setState(() {
      _pickedLat = lat;
      _pickedLng = lng;
      _pickedAddress = address;
      _searchController.text = address;
      _searchResults = [];
    });

    _mapController.move(LatLng(lat, lng), 16.0);
    FocusScope.of(context).unfocus();
  }

  void _confirmLocation() {
    Navigator.pop(
      context,
      LocationPickerResult(
        latitude: _pickedLat,
        longitude: _pickedLng,
        address: _pickedAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pick Location',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Color(0xFF0052CC),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_pickedLat, _pickedLng),
              initialZoom: 14.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.autofinder',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_pickedLat, _pickedLng),
                    width: 48,
                    height: 56,
                    child: const Icon(
                      Icons.location_pin,
                      color: Color(0xFF0052CC),
                      size: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Bar + Results
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchAddress,
                    decoration: InputDecoration(
                      hintText: 'Search street, area, or city...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                      prefixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0052CC),
                                ),
                              ),
                            )
                          : const Icon(Icons.search, color: Color(0xFF6B7280)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF6B7280),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                // Search Results Dropdown
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, _2) =>
                          const Divider(height: 1, indent: 48),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        final name = result['display_name'] as String;
                        return ListTile(
                          leading: const Icon(
                            Icons.place_outlined,
                            color: Color(0xFF0052CC),
                          ),
                          title: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // My Location Button
          Positioned(
            bottom: 250,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'myLocationBtn',
              backgroundColor: Colors.white,
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location, color: Color(0xFF0052CC)),
            ),
          ),

          // Bottom Address Card + Confirm
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Selected Location',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF0052CC),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isLoadingAddress
                            ? const LinearProgressIndicator(
                                color: Color(0xFF0052CC),
                                backgroundColor: Color(0xFFE5E7EB),
                              )
                            : Text(
                                _pickedAddress.isEmpty
                                    ? 'Tap on the map to select a location'
                                    : _pickedAddress,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                  height: 1.4,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${_pickedLat.toStringAsFixed(6)}, ${_pickedLng.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052CC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
