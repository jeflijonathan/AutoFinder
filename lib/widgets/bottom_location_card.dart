import 'package:flutter/material.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

class BottomLocationCard extends StatelessWidget {
  final String address;
  final double latitude;
  final double longitude;
  final bool isLoadingAddress;
  final VoidCallback onConfirm;

  const BottomLocationCard({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isLoadingAddress,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              theme.brightness == Brightness.dark ? 50 : 25,
            ),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar (Dekorasi)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            AppLocale.selectedLocation.getString(context),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: isLoadingAddress
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(
                          color: colorScheme.primary,
                          backgroundColor: colorScheme.outlineVariant,
                        ),
                      )
                    : Text(
                        address.isEmpty
                            ? AppLocale.tapMapToSelect.getString(context)
                            : address,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withAlpha(180),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocale.confirmLocation.getString(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
