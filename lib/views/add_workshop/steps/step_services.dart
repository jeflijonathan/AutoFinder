import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';
import 'package:autofinder/views/add_workshop/widgets/build_selected_item.dart';
import 'package:autofinder/views/add_workshop/widgets/service_picker_sheet.dart';
import 'package:autofinder/provider/service_category_provider.dart';

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
          itemCount: selected.length + 1,
          itemBuilder: (ctx, index) {
            if (index == selected.length) {
              return _buildAddButton(ctx, provider);
            }
            final name = selected[index];
            final data = ServiceCategoryProvider().allServices.firstWhere(
              (s) => s['name'] == name,
              orElse: () => {'name': name, 'icon': Icons.build_circle_outlined},
            );
            return BuildSelectedItem(
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

  Widget _buildAddButton(BuildContext ctx, AddWorkshopProvider provider) {
    return InkWell(
      onTap: () => _showServicePicker(ctx, provider),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0052CC).withValues(alpha: 0.35),
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
                color: const Color(0xFF0052CC).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 26, color: Color(0xFF0052CC)),
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
}
