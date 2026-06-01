import 'dart:async';
import 'dart:convert';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/widgets/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderImageSection extends StatefulWidget {
  final WorkshopModel workshop;

  const HeaderImageSection({super.key, required this.workshop});

  @override
  State<HeaderImageSection> createState() => _HeaderImageSectionState();
}

class _HeaderImageSectionState extends State<HeaderImageSection> {
  int _currentIndex = 0;
  late final PageController _pageController;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.workshop.image.length > 1) {
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % widget.workshop.image.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Background Image
        SizedBox(
          width: double.infinity,
          height: 300,
          child: widget.workshop.image.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: widget.workshop.image.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.memory(
                      base64Decode(widget.workshop.image[index].split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    );
                  },
                )
              : _buildPlaceholder(),
        ),
        
        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),

        // Page Indicator - vertical on right side
        if (widget.workshop.image.length > 1)
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.workshop.image.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    width: 6,
                    height: _currentIndex == index ? 20 : 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Content Overlay
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TranslatedText(
                      widget.workshop.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _FavoriteButton(workshopId: widget.workshop.uid ?? ''),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    widget.workshop.averageRating > 0 ? widget.workshop.averageRating.toStringAsFixed(1) : '0.0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.workshop.address,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.image, color: Colors.white54, size: 48),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final String workshopId;
  const _FavoriteButton({required this.workshopId});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.workshopId);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    if (_isFavorite) {
      favorites.remove(widget.workshopId);
    } else {
      favorites.add(widget.workshopId);
    }
    await prefs.setStringList('favorites', favorites);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.red.shade600,
        size: 20,
      ),
      onPressed: _toggleFavorite,
    );
  }
}
