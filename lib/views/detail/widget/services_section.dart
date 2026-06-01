import 'package:flutter/material.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:translator/translator.dart';

class ServicesSection extends StatelessWidget {
  final List<String> services;

  const ServicesSection({super.key, required this.services});

  static Future<String> translateLive(String text) async {
    if (text.trim().isEmpty) return '';

    final String targetLang =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';

    try {
      final translator = GoogleTranslator();
      final translation = await translator.translate(text, to: targetLang);

      return translation.text;
    } catch (e) {
      debugPrint("Gagal menerjemahkan teks database: $e");
      return text;
    }
  }

  Future<List<String>> _translateAllServices() async {
    // 2. Memanggil fungsi static menggunakan nama Class agar tidak membingungkan compiler
    final List<Future<String>> translationFutures = services.map((service) {
      return ServicesSection.translateLive(service);
    }).toList();

    return await Future.wait(translationFutures);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocale.availableServices.getString(context),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<String>>(
          future: _translateAllServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final displayList = snapshot.data ?? services;

            return Column(
              children: List.generate(displayList.length, (index) {
                final originalService = services[index].toLowerCase();
                final translatedService = displayList[index];

                IconData icon = Icons.build_circle_outlined;
                if (originalService.contains('oil') ||
                    originalService.contains('oli')) {
                  icon = Icons.oil_barrel_outlined;
                }
                if (originalService.contains('brake') ||
                    originalService.contains('rem')) {
                  icon = Icons.album_outlined;
                }
                if (originalService.contains('align') ||
                    originalService.contains('chassis') ||
                    originalService.contains('kaki') ||
                    originalService.contains('sasis')) {
                  icon = Icons.compare_arrows;
                }
                if (originalService.contains('ecu') ||
                    originalService.contains('remap') ||
                    originalService.contains('tune')) {
                  icon = Icons.memory;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.blue.shade700, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          translatedService,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
