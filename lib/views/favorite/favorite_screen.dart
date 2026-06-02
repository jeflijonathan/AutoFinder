import 'dart:convert';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/views/home/controller/home_controller.dart';
import 'package:autofinder/views/home/provider/home_page_provider.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:autofinder/widgets/navbar.dart';
import 'package:autofinder/widgets/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final HomeController _homeController = HomeController();
  List<String> _favoriteIds = [];
  bool _isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomePageProvider>();
      // Fetch workshops if not yet loaded
      if (homeProvider.state.data.isEmpty) {
        _homeController.fetchDataRequest(homeProvider);
      }
      _loadFavoriteIds();
    });
  }

  Future<void> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    if (mounted) {
      setState(() {
        _favoriteIds = favorites;
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _removeFavorite(String workshopId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    favorites.remove(workshopId);
    await prefs.setStringList('favorites', favorites);
    if (mounted) {
      setState(() {
        _favoriteIds = favorites;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final homeProvider = context.watch<HomePageProvider>();
    final isLoading = homeProvider.state.isLoading || _isLoadingFavorites;

    final favoriteWorkshops = homeProvider.state.data
        .where((w) => _favoriteIds.contains(w.uid))
        .toList();

    return Scaffold(
      appBar: const Navbar(),
      bottomNavigationBar: const ButtonNavBar(currentIndex: 2),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Gradient Background (same as home)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF0F172A),
                        const Color(0xFF1E293B),
                        theme.scaffoldBackgroundColor,
                      ]
                    : [
                        const Color(0xFFF9FAFB),
                        const Color(0xFFF3F4F6),
                        Colors.white,
                      ],
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadFavoriteIds,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Page Title
                        Text(
                          'Favorite Workshops',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoadingFavorites || isLoading
                              ? ''
                              : '${favoriteWorkshops.length} workshop tersimpan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),

                  // Content
                  if (isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (favoriteWorkshops.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(context, isDark, theme),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final workshop = favoriteWorkshops[index];
                            return _FavoriteWorkshopCard(
                              workshop: workshop,
                              onRemove: () =>
                                  _removeFavorite(workshop.uid ?? ''),
                            );
                          },
                          childCount: favoriteWorkshops.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isDark, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Favorit',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan workshop ke favorit dengan menekan ikon ❤️ pada halaman detail workshop.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/home'),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Cari Workshop'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Favorite Workshop Card
// ─────────────────────────────────────────────────────────────────────────────

class _FavoriteWorkshopCard extends StatelessWidget {
  final WorkshopModel workshop;
  final VoidCallback onRemove;

  const _FavoriteWorkshopCard({
    required this.workshop,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/detail', arguments: workshop),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with heart button
            Stack(
              children: [
                // Workshop Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: _buildImage(),
                ),

                // Gradient Overlay on image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Specialization Badge
                if (workshop.specialization.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        workshop.specialization.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                // Favorite (Remove) Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TranslatedText(
                          workshop.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rating Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              workshop.averageRating > 0
                                  ? workshop.averageRating
                                      .toStringAsFixed(1)
                                  : '0.0',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    workshop.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Address + Detail Button
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          workshop.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: workshop,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (workshop.image.isNotEmpty) {
      try {
        final imgStr = workshop.image.first.split(',').last;
        return Image.memory(
          base64Decode(imgStr),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) => _placeholder(),
        );
      } catch (_) {
        return _placeholder();
      }
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey, size: 48),
    );
  }
}
