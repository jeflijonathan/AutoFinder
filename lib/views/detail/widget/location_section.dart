import 'package:autofinder/views/detail/widget/full_screen_map.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

class LocationSection extends StatefulWidget {
  final String address;
  final String phoneNumber;
  final double latitude;
  final double longitude;

  const LocationSection({
    super.key,
    required this.address,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Mendapatkan kode bahasa aktif saat ini untuk disematkan ke URL Google Maps
    final String currentLangCode =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';

    // Perbaikan typo '1{widget.latitude}' menjadi '${widget.latitude}'
    // Penambahan '&hl=$currentLangCode' agar antarmuka peta mengikuti bahasa aplikasi
    final htmlContent =
        '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { margin: 0; padding: 0; }
          iframe { border: 0; width: 100%; height: 100vh; pointer-events: none; }
        </style>
      </head>
      <body>
        <iframe src="https://maps.google.com/maps?q=${widget.latitude},${widget.longitude}&hl=$currentLangCode&z=15&output=embed" allowfullscreen></iframe>
      </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlContent);
  }

  void _openFullScreenMap() {
    // Menggunakan terjemahan untuk Judul halaman Peta Penuh
    final String mapTitle = AppLocale.location.getString(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMap(
          latitude: widget.latitude,
          longitude: widget.longitude,
          title: mapTitle,
        ),
      ),
    );
  }

  Future<void> _launchMaps() async {
    // Perbaikan format URL maps universal yang kompatibel baik di Android maupun iOS
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch maps: $e');
    }
  }

  Future<void> _launchPhone() async {
    final url = Uri.parse('tel:${widget.phoneNumber}');
    try {
      await launchUrl(url);
    } catch (e) {
      debugPrint('Could not launch phone: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocale.locationTitle.getString(
              context,
            ), // "LOCATION" Terlokalisasi
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Google Maps Iframe via WebView
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  // Transparent overlay to catch taps
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(onTap: _openFullScreenMap),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey : Colors.grey,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _launchMaps,
                  icon: const Icon(
                    Icons.directions,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    AppLocale.getDirections.getString(
                      context,
                    ), // "Get Directions" Terlokalisasi
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _launchPhone,
                  icon: Icon(
                    Icons.phone,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                  label: Text(
                    AppLocale.call.getString(context), // "Call" Terlokalisasi
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
