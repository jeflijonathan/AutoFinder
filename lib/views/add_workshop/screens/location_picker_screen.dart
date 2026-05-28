// lib/screens/location_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:autofinder/controllers/location_picker_controller.dart';
import 'package:autofinder/models/location_picker_result.dart';
import 'package:autofinder/widgets/map_search_bar.dart';
import 'package:autofinder/widgets/bottom_location_card.dart';

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
  final LocationPickerController _controller = LocationPickerController();

  @override
  void initState() {
    super.initState();
    _controller.initialize(
      initialLat: widget.initialLat,
      initialLng: widget.initialLng,
      initialAddress: widget.initialAddress,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmLocation() {
    Navigator.pop(
      context,
      LocationPickerResult(
        latitude: _controller.pickedLat,
        longitude: _controller.pickedLng,
        address: _controller.pickedAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: colorScheme.onSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Pick Location',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _confirmLocation,
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _controller.mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    _controller.pickedLat,
                    _controller.pickedLng,
                  ),
                  initialZoom: 14.0,
                  onTap: _controller.onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.autofinder',
                    tileBuilder: theme.brightness == Brightness.dark
                        ? (context, tileWidget, tile) {
                            return ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                -0.87,
                                0.0,
                                0.0,
                                0.0,
                                255.0,
                                0.0,
                                -0.87,
                                0.0,
                                0.0,
                                255.0,
                                0.0,
                                0.0,
                                -0.87,
                                0.0,
                                255.0,
                                0.0,
                                0.0,
                                0.0,
                                1.0,
                                0.0,
                              ]),
                              child: tileWidget,
                            );
                          }
                        : null,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          _controller.pickedLat,
                          _controller.pickedLng,
                        ),
                        width: 48,
                        height: 56,
                        child: Icon(
                          Icons.location_pin,
                          color: colorScheme.primary,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: MapSearchBar(
                  controller: _controller.searchController,
                  onChanged: _controller.searchAddress,
                  isSearching: _controller.isSearching,
                  searchResults: _controller.searchResults,
                  onSelectResult: (result) =>
                      _controller.selectSearchResult(result, context),
                  onClear: _controller.clearSearch,
                ),
              ),

              Positioned(
                bottom: 250,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'myLocationBtn',
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.primary,
                  onPressed: _controller.getCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),

              // 4. Bottom Layer: Summary Card Komponen
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomLocationCard(
                  address: _controller.pickedAddress,
                  latitude: _controller.pickedLat,
                  longitude: _controller.pickedLng,
                  isLoadingAddress: _controller.isLoadingAddress,
                  onConfirm: _confirmLocation,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
