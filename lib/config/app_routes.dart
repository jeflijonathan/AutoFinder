import 'package:flutter/material.dart';
import '../views/auth/welcome_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/home/home_screen.dart';

class AppRoutes {
  // 1. DAFTAR NAMA ALAMAT (URL/PATH)
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String admin = '/admin';

  // 2. PEMETAAN NAMA KE WIDGET HALAMAN
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const WelcomeScreen(),     // Root entry is the Welcome Screen
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      dashboard: (context) => const HomeScreen(),   // User dashboard landing page
      admin: (context) => const HomeScreen(),       // Admin dashboard placeholder
    };
  }
}
