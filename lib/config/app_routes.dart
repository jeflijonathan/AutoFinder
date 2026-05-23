import 'package:autofinder/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/views/auth/welcome_screen.dart';
import 'package:autofinder/views/auth/login_screen.dart';
import 'package:autofinder/views/auth/register_screen.dart';
import 'package:autofinder/views/profile/profile_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return child;
  }
}

class GuestGuard extends StatelessWidget {
  final Widget child;
  const GuestGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return child;
  }
}

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const GuestGuard(child: WelcomeScreen()),
      login: (context) => const GuestGuard(child: LoginScreen()),
      register: (context) => const GuestGuard(child: RegisterScreen()),
      home: (context) => const AuthGuard(child: HomeScreen()),
      profile: (context) => const AuthGuard(child: ProfileScreen()),
    };
  }
}
