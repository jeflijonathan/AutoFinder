import 'package:autofinder/views/home/controller/home_controller.dart';
import 'package:autofinder/views/home/controller/home_filter_controller.dart';
import 'package:autofinder/views/home/provider/home_page_provider.dart';
import 'package:autofinder/views/home/widget/search_bar.dart';
import 'package:autofinder/views/home/widget/workshop_list.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:autofinder/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/controllers/location_controller.dart';
import 'package:autofinder/config/app_locale.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController homeController = HomeController();
  final HomeFilterController filterController = HomeFilterController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomePageProvider>();
      homeController.fetchDataRequest(homeProvider);
      context.read<LocationController>().fetchUserLocation();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final homeProvider = context.watch<HomePageProvider>();
    final workshopList = homeProvider.state.data;
    final searchValue = homeProvider.state.params.values.toLowerCase();
    final filteredWorkshops = workshopList.where((w) {
      return w.title.toLowerCase().contains(searchValue) ||
          w.specialization.toLowerCase().contains(searchValue);
    }).toList();

    final featuredList = filteredWorkshops.take(3).toList();
    final nearbyList = filteredWorkshops;

    return Scaffold(
      appBar: const Navbar(),
      bottomNavigationBar: const ButtonNavBar(currentIndex: 0),
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
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocale.findWorkshop.getString(context),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 24),

                      HomeSearchBar(
                        controller: searchController,
                        hintText: AppLocale.findSpecialist.getString(context),
                        readOnly: true,
                        onTap: () => Navigator.pushNamed(context, '/search'),
                        onChanged: (value) =>
                            filterController.onSearchChanged(context, value),
                      ),
                      const SizedBox(height: 32),

                      if (homeProvider.state.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocale.featuredWorkshops.getString(context),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                AppLocale.viewAll.getString(context),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        WorkshopList(
                          workshops: featuredList,
                          listType: WorkshopListType.featured,
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocale.workshopNearby.getString(context),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.map_outlined,
                                size: 20,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Consumer<LocationController>(
                          builder: (context, locationController, child) {
                            if (locationController.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return WorkshopList(
                              workshops: nearbyList,
                              listType: WorkshopListType.nearby,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
