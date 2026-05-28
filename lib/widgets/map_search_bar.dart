import 'package:flutter/material.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final List<Map<String, dynamic>> searchResults;
  final ValueChanged<Map<String, dynamic>> onSelectResult;
  final bool isSearching;

  const MapSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.searchResults,
    required this.onSelectResult,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Input Box
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(
                  theme.brightness == Brightness.dark ? 40 : 30,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search street, area, or city...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withAlpha(150),
                fontSize: 14,
              ),
              prefixIcon: isSearching
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: onClear,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),

        // Search Results Overlay
        if (searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(
                    theme.brightness == Brightness.dark ? 40 : 30,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: searchResults.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 48,
                color: colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final result = searchResults[index];
                final name = result['display_name'] as String;
                return ListTile(
                  leading: Icon(
                    Icons.place_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: () => onSelectResult(result),
                );
              },
            ),
          ),
      ],
    );
  }
}
