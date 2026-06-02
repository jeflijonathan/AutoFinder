import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/widgets/search_bar_debounced.dart';
import 'package:autofinder/views/home/widget/workshop_list.dart';
import 'package:autofinder/views/search/controller/search_controller.dart'
    as search_ctrl;
import 'package:autofinder/views/search/provider/search_page_provider.dart';
import 'package:autofinder/views/search/widget/filter_chips.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final search_ctrl.SearchController _searchController =
      search_ctrl.SearchController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SearchPageProvider>();
      _searchController.fetchDataRequest(provider);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<SearchPageProvider>();
    final state = provider.state;

    final query = state.searchQuery.toLowerCase();
    var filteredList = state.data.where((w) {
      return w.title.toLowerCase().contains(query) ||
          w.specialization.toLowerCase().contains(query);
    }).toList();

    if (state.topRated) {
      filteredList = filteredList.where((w) => w.averageRating >= 4.0).toList();
    }

    if (state.selectedSpecializations.isNotEmpty) {
      filteredList = filteredList
          .where(
            (w) => state.selectedSpecializations.any(
              (s) => s.toLowerCase() == w.specialization.toLowerCase(),
            ),
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          AppLocale.search.getString(context).toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    SearchBarDebounced(
                      controller: _textController,
                      hintText: AppLocale.findSpecialist.getString(context),
                      autofocus: true,
                      isLoading: state.searchLoading,
                      debounceMs: 600,
                      onChanged: (val) =>
                          _searchController.onSearchChanged(provider, val),
                      onDebouncedChange: (val) =>
                          _searchController.onSearchDebounced(provider, val),
                    ),
                    const SizedBox(height: 16),
                    FilterChips(
                      openNowSelected: state.openNow,
                      topRatedSelected: state.topRated,
                      onOpenNowTap: () =>
                          _searchController.toggleOpenNow(provider),
                      onTopRatedTap: () =>
                          _searchController.toggleTopRated(provider),
                      onMoreFiltersTap: () {
                        _showMoreFiltersSheet(context, provider);
                      },
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : WorkshopList(
                              workshops: filteredList,
                              listType: WorkshopListType.nearby,
                              physics: const BouncingScrollPhysics(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreFiltersSheet(
    BuildContext context,
    SearchPageProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            final Map<String, String> specializationMap = {
              'car': 'Car',
              'motorcycle': 'Motorcycle',
              'truck': 'Truck',
            };

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'More Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Specialization',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: specializationMap.entries.map((entry) {
                      final isSelected = provider.state.selectedSpecializations
                          .any(
                            (s) => s.toLowerCase() == entry.key.toLowerCase(),
                          );
                      return FilterChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (val) {
                          _searchController.toggleSpecialization(
                            provider,
                            entry.key,
                          );
                          setState(() {});
                        },
                        selectedColor: theme.colorScheme.primary.withAlpha(50),
                        checkmarkColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
