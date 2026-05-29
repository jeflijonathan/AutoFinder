import 'package:flutter/material.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ServicePickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> allServices;
  final List<String> selectedServices;
  final void Function(List<String>) onSubmit;

  const ServicePickerSheet({
    super.key,
    required this.allServices,
    required this.selectedServices,
    required this.onSubmit,
  });

  @override
  State<ServicePickerSheet> createState() => ServicePickerSheetState();
}

class ServicePickerSheetState extends State<ServicePickerSheet> {
  late List<String> _tempSelected;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedServices);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return widget.allServices;
    return widget.allServices
        .where(
          (s) => (s['name'] as String).toLowerCase().contains(
            _query.toLowerCase(),
          ),
        )
        .toList();
  }

  void _toggle(String name) {
    setState(() {
      if (_tempSelected.contains(name)) {
        _tempSelected.remove(name);
      } else {
        _tempSelected.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF444444)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocale.chooseService.getString(context),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface, // Teks adaptif
                        ),
                      ),
                    ),
                    if (_tempSelected.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(
                            25,
                          ), // Background badge dinamis
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_tempSelected.length} ${AppLocale.selected.getString(context)}',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: AppLocale.searchService.getString(context),
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Daftar Layanan
              Expanded(
                child: _filtered.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final svc = _filtered[i];
                          final name = svc['name'] as String;
                          final icon = svc['icon'] as IconData;
                          final sel = _tempSelected.contains(name);
                          return _buildListItem(theme, name, icon, sel);
                        },
                      ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSubmit(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: isDark
                          ? const Color(0xFF3A4B5C)
                          : const Color(0xFFB0C4DE),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _tempSelected.isEmpty
                          ? AppLocale.confirmSelection.getString(context)
                          : '${AppLocale.save.getString(context)}${_tempSelected.length}${AppLocale.servicesLabel.getString(context)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListItem(
    ThemeData theme,
    String name,
    IconData icon,
    bool isSelected,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => _toggle(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withAlpha(20) // Highlight transparan warna utama
              : (isDark ? const Color(0xFF232323) : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withAlpha(40)
                    : (isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFEEEFF1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? primaryColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: FutureBuilder<String>(
                future: AppLocale.translateLive(name),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? primaryColor
                          : theme.colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDark
                            ? const Color(0xFF555555)
                            : const Color(0xFFD1D5DB)),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF444444)
                : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '${AppLocale.serviceNotFound.getString(context).replaceAll(' ', '') == 'tidakditemukan' ? 'Layanan ' : ''}"$_query"${AppLocale.serviceNotFound.getString(context)}',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
