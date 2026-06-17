import 'dart:convert';
import 'dart:math';
import 'package:autofinder/controllers/location_controller.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/widgets/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum WorkshopListType { featured, nearby }

class WorkshopList extends StatelessWidget {
  final List<WorkshopModel> workshops;
  final WorkshopListType listType;
  final ScrollPhysics? physics;

  const WorkshopList({
    super.key,
    required this.workshops,
    required this.listType,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (workshops.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Tidak ada data workshop.'),
        ),
      );
    }

    if (listType == WorkshopListType.featured) {
      return SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: workshops.length,
          itemBuilder: (context, index) {
            final item = workshops[index];
            return _buildFeaturedCard(context, item);
          },
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: physics ?? const NeverScrollableScrollPhysics(),
        itemCount: workshops.length,
        itemBuilder: (context, index) {
          final item = workshops[index];
          return _buildNearbyCard(context, item);
        },
      );
    }
  }

  double? _calculateDistance(
    double? userLat,
    double? userLng,
    double workshopLat,
    double workshopLng,
  ) {
    if (userLat == null || userLng == null) return null;
    const earthRadius = 6371.0;
    final dLat = _toRad(workshopLat - userLat);
    final dLng = _toRad(workshopLng - userLng);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(userLat)) *
            cos(_toRad(workshopLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  String _formatDistance(double? km) {
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  Widget _buildFeaturedCard(BuildContext context, WorkshopModel item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = context.watch<LocationController>();
    final distance = _calculateDistance(
      loc.latitude,
      loc.longitude,
      item.latitude,
      item.longitude,
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: item);
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: item.image.isNotEmpty
                  ? Image.memory(
                      base64Decode(
                        (item.image.length > 1
                                ? item.image[1]
                                : item.image.first)
                            .split(',')
                            .last,
                      ),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TranslatedText(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildRatingBadge(item.averageRating),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.build, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TranslatedText(
                          item.specialization.isNotEmpty
                              ? item.specialization
                              : 'General Repair',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (distance != null) ...[
                    const SizedBox(height: 6),
                    _buildDistanceBadge(context, _formatDistance(distance)),
                  ],
                  if (item.priceEstimate != null && item.priceEstimate!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildPriceBadge(context, item.priceEstimate!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyCard(BuildContext context, WorkshopModel item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = context.watch<LocationController>();
    final distance = _calculateDistance(
      loc.latitude,
      loc.longitude,
      item.latitude,
      item.longitude,
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.image.isNotEmpty
                    ? Image.memory(
                        base64Decode(
                          (item.image.length > 1
                                  ? item.image[1]
                                  : item.image.first)
                              .split(',')
                              .last,
                        ),
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(size: 80),
                      )
                    : _buildPlaceholderImage(size: 80),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TranslatedText(
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildRatingBadge(item.averageRating),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TranslatedText(
                      item.specialization.isNotEmpty
                          ? item.specialization
                          : 'General Repair',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (distance != null) ...[
                      const SizedBox(height: 6),
                      _buildDistanceBadge(context, _formatDistance(distance)),
                    ],
                    if (item.priceEstimate != null && item.priceEstimate!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildPriceBadge(context, item.priceEstimate!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage({double size = 140}) {
    return Container(
      height: size,
      width: size == 140 ? double.infinity : size,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildPriceBadge(BuildContext context, String price) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.payments_outlined,
          size: 12,
          color: isDark ? Colors.green[300] : Colors.green[700],
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            price,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.green[300] : Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceBadge(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          size: 12,
          color: isDark ? Colors.blue[300] : Colors.blue[600],
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark ? Colors.blue[300] : Colors.blue[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: Colors.orange.shade800),
          const SizedBox(width: 2),
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : '0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
