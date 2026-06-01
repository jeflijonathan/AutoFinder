import 'package:autofinder/utils/snackbar.dart';
import 'package:autofinder/views/home/provider/home_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/firebase_options.dart';
import 'package:autofinder/config/app_routes.dart';
import 'package:autofinder/config/app_theme.dart';
import 'package:autofinder/controllers/location_controller.dart';
import 'package:autofinder/controllers/location_picker_controller.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('theme_mode');

  if (savedTheme == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  } else if (savedTheme == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else {
    themeNotifier.value = ThemeMode.system;
  }

  themeNotifier.addListener(() async {
    final currentPrefs = await SharedPreferences.getInstance();
    if (themeNotifier.value == ThemeMode.dark) {
      await currentPrefs.setString('theme_mode', 'dark');
    } else if (themeNotifier.value == ThemeMode.light) {
      await currentPrefs.setString('theme_mode', 'light');
    } else {
      await currentPrefs.setString('theme_mode', 'system');
    }
  });

  final String savedLanguage = prefs.getString('language_code') ?? 'en';

  await FlutterLocalization.instance.ensureInitialized();
  FlutterLocalization.instance.init(
    mapLocales: [
      const MapLocale('en', AppLocale.EN),
      const MapLocale('id', AppLocale.ID),
      const MapLocale('ja', AppLocale.JA),
      const MapLocale('th', AppLocale.TH),
      const MapLocale('zh', AppLocale.ZH),
    ],
    initLanguageCode: savedLanguage,
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization skipped or failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LocationController()),
        ChangeNotifierProvider(create: (_) => LocationPickerController()),
        ChangeNotifierProvider(create: (_) => HomePageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    localization.onTranslatedLanguage = _onTranslatedLanguage;
    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          scaffoldMessengerKey: SnackbarHelper.messengerKey,
          title: 'Auto Finder',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          supportedLocales: localization.supportedLocales,
          localizationsDelegates: localization.localizationsDelegates,
          initialRoute: AppRoutes.welcome,
          routes: AppRoutes.getRoutes(),
        );
      },
    );
  }
}
