import 'package:autofinder/provider/add_workshop_provider.dart';
import 'package:autofinder/provider/service_category_provider.dart';
import 'package:autofinder/views/add_workshop/widgets/build_selected_item.dart';
import 'package:autofinder/views/add_workshop/widgets/service_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepServices extends StatelessWidget {
  const StepServices({super.key});

  void _showServicePicker(BuildContext context, AddWorkshopProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServicePickerSheet(
        allServices: ServiceCategoryProvider().allServices,
        selectedServices: List.from(provider.selectedServices),
        onSubmit: (newSelected) {
          for (final svc in List.from(provider.selectedServices)) {
            if (!newSelected.contains(svc)) {
              provider.toggleService(svc);
            }
          }

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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Capabilities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the specialized services your atelier provides.',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
          itemCount: selected.length + 1,
          itemBuilder: (ctx, index) {
            if (index == selected.length) {
              return _buildAddButton(ctx, theme, provider);
            }
            final name = selected[index];
            final data = ServiceCategoryProvider().allServices.firstWhere(
              (s) => s['name'] == name,
              orElse: () => {'name': name, 'icon': Icons.build_circle_outlined},
            );
            return BuildSelectedItem(
              icon: data['icon'] as IconData,
              title: name,
              onRemove: () => provider.toggleService(name),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddButton(
    BuildContext ctx,
    ThemeData theme,
    AddWorkshopProvider provider,
  ) {
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _showServicePicker(ctx, provider),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          // Warna latar tombol tambah adaptif terhadap mode kegelapan sistem
          color: isDark ? primaryColor.withAlpha(20) : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withAlpha(
              90,
            ), // Border opacity disesuaikan (~35%)
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
                color: primaryColor.withAlpha(
                  30,
                ), // Lingkaran icon tambah transparan
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 26, color: primaryColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Add Service',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
