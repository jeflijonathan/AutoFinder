import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';
import 'package:autofinder/views/add_workshop/utils/workshop_form_validator.dart';
import 'package:autofinder/widgets/custom_textfield.dart';
import 'package:autofinder/widgets/phone_number_textfield.dart';

class StepIdentity extends StatelessWidget {
  const StepIdentity({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddWorkshopProvider>(context);

    return Form(
      key: provider.identityFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workshop Identity',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Define your brand and core operational details.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          PhoneNumberTextField(
            label: 'PHONE NUMBER',
            controller: provider.phoneController,
            validator: WorkshopValidators.phone,
            onCountryChanged: (code) {
              provider.setCountryCode(code);
            },
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'WORKSHOP NAME',
            hintText: 'e.g. Precision Gearhead Labs',
            controller: provider.nameController,
            keyboardType: TextInputType.text,
            validator: WorkshopValidators.name,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'MISSION STATEMENT',
            hintText:
                'Describe your technical\nexpertise and workshop\nvalues...',
            controller: provider.missionController,
            keyboardType: TextInputType.text,
            validator: WorkshopValidators.mission,
            minLines: 4,
            maxLines: 6,
          ),
          const SizedBox(height: 24),
          const Text(
            'SPECIALIZATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.selectedSpecialization,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF6B7280),
                ),
                items: <String>['car', 'motorcycle', 'truck']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    provider.setSpecialization(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
