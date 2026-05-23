import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_routes.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization skipped or failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthController())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Finder',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.getRoutes(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B51C1),
          primary: const Color(0xFF0B51C1),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
    );
  }
}
