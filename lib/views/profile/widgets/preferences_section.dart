import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/main.dart';
import 'package:autofinder/views/profile/widgets/group_section.dart';
import 'package:autofinder/views/profile/widgets/menu_tile.dart';

class PreferencesSection extends StatelessWidget {
  final bool isDark;

  const PreferencesSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final tileBgColor = isDark ? AppColors.cardBgDark : AppColors.cardBgLight;

    final FlutterLocalization localization = FlutterLocalization.instance;
    final String currentLang = localization.currentLocale?.languageCode ?? 'en';

    return GroupSection(
      title: AppLocale.preferences.getString(context),
      children: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentTheme, child) {
            return MenuTile(
              icon: Icons.dark_mode_outlined,
              iconColor: AppColors.primary,
              iconBgColor: tileBgColor,
              title: AppLocale.theme.getString(context),
              subtitle: AppLocale.themeSubtitle.getString(context),
              trailing: Switch(
                value: currentTheme == ThemeMode.dark,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  themeNotifier.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        MenuTile(
          icon: Icons.language_outlined,
          iconColor: AppColors.primary,
          iconBgColor: tileBgColor,
          title: AppLocale.language.getString(context),
          subtitle: AppLocale.languageSubtitle.getString(context),
          trailing: DropdownButton<String>(
            value: currentLang,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
              DropdownMenuItem(value: 'id', child: Text('🇮🇩 Indonesia')),
              DropdownMenuItem(value: 'ja', child: Text('🇯🇵 日本語')),
              DropdownMenuItem(value: 'th', child: Text('🇹🇭 ไทย')),
              DropdownMenuItem(value: 'zh', child: Text('🇨🇳 中文')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                localization.translate(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
}
