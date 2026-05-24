import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';
import 'package:autofinder/views/add_workshop/screens/location_picker_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StepLocation extends StatelessWidget {
  const StepLocation({super.key});

  Future<void> _openPicker(
    BuildContext context,
    AddWorkshopProvider provider,
  ) async {
    final result = await Navigator.push<LocationPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLat: provider.latitude,
          initialLng: provider.longitude,
          initialAddress: provider.address,
        ),
      ),
    );
    if (result != null) {
      provider.setLocation(result.latitude, result.longitude);
      provider.setAddress(result.address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddWorkshopProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deployment Location',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pin your workshop on our technical\nnetwork map.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 32),

        GestureDetector(
          onTap: () => _openPicker(context, provider),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                IgnorePointer(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        provider.latitude,
                        provider.longitude,
                      ),
                      initialZoom: 14.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.autofinder',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              provider.latitude,
                              provider.longitude,
                            ),
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
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_location_alt_outlined,
                          size: 14,
                          color: Color(0xFF0052CC),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0052CC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => _openPicker(context, provider),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.address.isEmpty ? 'Address' : provider.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: provider.address.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (provider.address.isNotEmpty)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF0052CC),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
