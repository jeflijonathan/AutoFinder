import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/models/location_picker_result.dart';
import 'package:autofinder/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/views/my_post/provider/edit_workshop_provider.dart';
import 'package:autofinder/views/add_workshop/screens/location_picker_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_localization/flutter_localization.dart';

class StepLocation extends StatelessWidget {
  const StepLocation({super.key});

  Future<void> _openPicker(
    BuildContext context,
    EditWorkshopProvider provider,
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
    final provider = Provider.of<EditWorkshopProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final mapTileUrl = isDark
        ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Header(
          title: AppLocale.locationTitle.getString(context), // 🟢 Diubah
          subtitle: AppLocale.locationSubtitle.getString(context), // 🟢 Diubah
        ),

        const SizedBox(height: 32),

        GestureDetector(
          onTap: () => _openPicker(context, provider),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
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
                        urlTemplate: mapTileUrl,
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
                            child: Icon(
                              Icons.location_pin,
                              color: primaryColor,
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
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 40 : 25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_location_alt_outlined,
                          size: 14,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocale.locationChange.getString(context),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
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
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.address.isEmpty
                        ? AppLocale.locationAddressHint.getString(context)
                        : provider.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: provider.address.isEmpty
                          ? theme.colorScheme.onSurfaceVariant.withAlpha(150)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (provider.address.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, color: primaryColor, size: 20),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
