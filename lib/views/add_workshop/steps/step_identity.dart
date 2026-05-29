import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';
import 'package:autofinder/views/add_workshop/utils/workshop_form_validator.dart';
import 'package:autofinder/widgets/custom_textfield.dart';
import 'package:autofinder/widgets/phone_number_textfield.dart';
import 'package:flutter_localization/flutter_localization.dart';

class StepIdentity extends StatelessWidget {
  const StepIdentity({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddWorkshopProvider>(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: provider.identityFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(
            title: AppLocale.identityTitle.getString(context),
            subtitle: AppLocale.identitySubtitle.getString(context),
          ),

          const SizedBox(height: 32),
          PhoneNumberTextField(
            label: AppLocale.phoneLabel.getString(context),
            controller: provider.phoneController,
            validator: WorkshopValidators.phone,
            onCountryChanged: (code) {
              provider.setCountryCode(code);
            },
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: AppLocale.workshopNameLabel.getString(context),
            hintText: AppLocale.workshopNameHint.getString(context),
            controller: provider.nameController,
            keyboardType: TextInputType.text,
            validator: WorkshopValidators.name,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: AppLocale.missionLabel.getString(context),
            hintText: AppLocale.missionHint.getString(context),
            controller: provider.missionController,
            keyboardType: TextInputType.text,
            validator: WorkshopValidators.mission,
            minLines: 4,
            maxLines: 6,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocale.specializationLabel.getString(context), // 🟢 Diubah
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: provider.selectedSpecialization,
              dropdownColor: theme.cardColor,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                fillColor: isDark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFF9FAFB),
                filled: true,

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 1.5,
                  ),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2.0,
                  ),
                ),
              ),
              items: <String>['car', 'motorcycle', 'truck']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value.toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
        ],
      ),
    );
  }
}
