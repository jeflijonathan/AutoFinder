import 'package:autofinder/utils/debounce.dart';
import 'package:flutter/material.dart';

class SearchBarDebounced extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int debounceMs;
  final void Function(String query) onDebouncedChange;
  final void Function(String query)? onChanged;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isLoading;

  const SearchBarDebounced({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onDebouncedChange,
    this.onChanged,
    this.debounceMs = 500,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.isLoading = false,
  });

  @override
  State<SearchBarDebounced> createState() => _SearchBarDebouncedState();
}

class _SearchBarDebouncedState extends State<SearchBarDebounced> {
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: widget.debounceMs);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: widget.controller,
        autofocus: widget.autofocus,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        style: theme.textTheme.bodyMedium,
        onChanged: (value) {
          widget.onChanged?.call(value);
          _debouncer.run(() => widget.onDebouncedChange(value));
        },
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          // Show a tiny loading indicator inside the search bar when debounce fires
          suffixIcon: widget.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
