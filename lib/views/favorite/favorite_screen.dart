import 'package:autofinder/views/home/controller/home_controller.dart';
import 'package:autofinder/views/home/provider/home_page_provider.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:autofinder/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autofinder/views/favorite/widgets/favorite_empty_state.dart';
import 'package:autofinder/views/favorite/widgets/favorite_workshop_card.dart';

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
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),

                  if (isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (favoriteWorkshops.isEmpty)
                    const SliverFillRemaining(child: FavoriteEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final workshop = favoriteWorkshops[index];
                          return FavoriteWorkshopCard(
                            workshop: workshop,
                            onRemove: () => _removeFavorite(workshop.uid ?? ''),
                          );
                        }, childCount: favoriteWorkshops.length),
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
}
