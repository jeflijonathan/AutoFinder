import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';

class StepServices extends StatelessWidget {
  const StepServices({super.key});

  /// Master list of all available services with icons
  static const List<Map<String, dynamic>> _allServices = [
    {'name': 'Lube & Oil', 'icon': Icons.oil_barrel_outlined},
    {'name': 'Suspension', 'icon': Icons.car_repair_outlined},
    {'name': 'Electrical', 'icon': Icons.electric_bolt_outlined},
    {'name': 'Brake Service', 'icon': Icons.album_outlined},
    {'name': 'Tire Service', 'icon': Icons.tire_repair_outlined},
    {'name': 'AC & Cooling', 'icon': Icons.ac_unit_outlined},
    {'name': 'Engine Repair', 'icon': Icons.settings_outlined},
    {'name': 'Transmission', 'icon': Icons.swap_horiz_outlined},
    {'name': 'Body Repair', 'icon': Icons.car_crash_outlined},
    {'name': 'Paint & Polish', 'icon': Icons.format_paint_outlined},
    {'name': 'Wheel Alignment', 'icon': Icons.rotate_right_outlined},
    {'name': 'Exhaust System', 'icon': Icons.air_outlined},
    {'name': 'Battery', 'icon': Icons.battery_charging_full_outlined},
    {'name': 'Detailing', 'icon': Icons.cleaning_services_outlined},
    {'name': 'Inspection', 'icon': Icons.search_outlined},
    {'name': 'Radiator', 'icon': Icons.thermostat_outlined},
    {'name': 'Steering', 'icon': Icons.radio_button_checked_outlined},
    {'name': 'Clutch', 'icon': Icons.circle_outlined},
  ];

  void _showServicePicker(
      BuildContext context, AddWorkshopProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServicePickerSheet(
        allServices: _allServices,
        selectedServices: List.from(provider.selectedServices),
        onSubmit: (newSelected) {
          // Remove unchecked
          for (final svc in List.from(provider.selectedServices)) {
            if (!newSelected.contains(svc)) {
              provider.toggleService(svc);
            }
          }
          // Add newly checked
          for (final svc in newSelected) {
            if (!provider.selectedServices.contains(svc)) {
              provider.toggleService(svc);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddWorkshopProvider>(context);
    final selected = provider.selectedServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Capabilities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the specialized services your atelier provides.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: selected.length + 1, // +1 for the Add button
          itemBuilder: (ctx, index) {
            if (index == selected.length) {
              return _buildAddButton(ctx, provider);
            }
            final name = selected[index];
            final data = _allServices.firstWhere(
              (s) => s['name'] == name,
              orElse: () =>
                  {'name': name, 'icon': Icons.build_circle_outlined},
            );
            return _buildSelectedItem(
              context: ctx,
              icon: data['icon'] as IconData,
              title: name,
              onRemove: () => provider.toggleService(name),
            );
          },
        ),
      ],
    );
  }

  // ─── Add (+) button card ───────────────────────────────────────────────────

  Widget _buildAddButton(BuildContext ctx, AddWorkshopProvider provider) {
    return InkWell(
      onTap: () => _showServicePicker(ctx, provider),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0052CC).withOpacity(0.35),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0052CC).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 26,
                color: Color(0xFF0052CC),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add Service',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0052CC),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Selected service card ─────────────────────────────────────────────────

  Widget _buildSelectedItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0052CC).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0052CC),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: const Color(0xFF0052CC)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0052CC),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Remove (×) badge
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D4F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Service Picker Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════

class _ServicePickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> allServices;
  final List<String> selectedServices;
  final void Function(List<String>) onSubmit;

  const _ServicePickerSheet({
    required this.allServices,
    required this.selectedServices,
    required this.onSubmit,
  });

  @override
  State<_ServicePickerSheet> createState() => _ServicePickerSheetState();
}

class _ServicePickerSheetState extends State<_ServicePickerSheet> {
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
        .where((s) =>
            (s['name'] as String).toLowerCase().contains(_query.toLowerCase()))
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
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────────────
              const SizedBox(height: 14),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pilih Layanan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (_tempSelected.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_tempSelected.length} dipilih',
                          style: const TextStyle(
                            color: Color(0xFF0052CC),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Search Bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Cari layanan...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF6B7280)),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Color(0xFF6B7280), size: 20),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Service List ─────────────────────────────────────────────
              Expanded(
                child: _filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final svc = _filtered[i];
                          final name = svc['name'] as String;
                          final icon = svc['icon'] as IconData;
                          final sel = _tempSelected.contains(name);
                          return _buildListItem(name, icon, sel);
                        },
                      ),
              ),

              // ── Submit Button ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    MediaQuery.of(context).viewInsets.bottom + 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSubmit(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      disabledBackgroundColor: const Color(0xFFB0C4DE),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _tempSelected.isEmpty
                          ? 'Konfirmasi Pilihan'
                          : 'Simpan ${_tempSelected.length} Layanan',
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

  // ── Single list item ───────────────────────────────────────────────────────

  Widget _buildListItem(String name, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggle(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0052CC).withOpacity(0.07)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0052CC)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon box
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0052CC).withOpacity(0.15)
                    : const Color(0xFFEEEFF1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? const Color(0xFF0052CC)
                    : const Color(0xFF6B7280),
              ),
            ),

            const SizedBox(width: 16),

            // Service name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF0052CC)
                      : const Color(0xFF1F2937),
                ),
              ),
            ),

            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0052CC)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0052CC)
                      : const Color(0xFFD1D5DB),
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

  // ── Empty search state ─────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Layanan "$_query" tidak ditemukan',
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
