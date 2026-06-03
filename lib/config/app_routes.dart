import 'package:autofinder/views/home/home_screen.dart';
import 'package:autofinder/views/search/search_screen.dart';
import 'package:autofinder/views/search/provider/search_page_provider.dart';
import 'package:autofinder/views/add_workshop/add_workshop_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/views/auth/welcome_screen.dart';
import 'package:autofinder/views/auth/login_screen.dart';
import 'package:autofinder/views/auth/register_screen.dart';
import 'package:autofinder/views/profile/profile_screen.dart';
import 'package:autofinder/views/profile/screens/edit_profile_screen.dart';
import 'package:autofinder/views/profile/screens/account_security_screen.dart';
import 'package:autofinder/views/detail/detail_screen.dart';
import 'package:autofinder/views/detail/provider/detail_page_provider.dart';
import 'package:autofinder/views/my_post/my_post_screen.dart';
import 'package:autofinder/views/my_post/provider/my_post_provider.dart';
import 'package:autofinder/views/favorite/favorite_screen.dart';

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
  static const String search = '/search';
  static const String profile = '/profile';
  static const String addWorkshop = '/add-workshop';
  static const String editProfile = '/edit-profile';
  static const String accountSecurity = '/account-security';
  static const String detail = '/detail';
  static const String myPost = '/my-post';
  static const String favorite = '/favorite';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const GuestGuard(child: WelcomeScreen()),
      login: (context) => const GuestGuard(child: LoginScreen()),
      register: (context) => const GuestGuard(child: RegisterScreen()),
      home: (context) => const AuthGuard(child: HomeScreen()),
      search: (context) => AuthGuard(
        child: ChangeNotifierProvider(
          create: (_) => SearchPageProvider(),
          child: const SearchScreen(),
        ),
      ),
      profile: (context) => const AuthGuard(child: ProfileScreen()),
      addWorkshop: (context) => const AuthGuard(child: AddWorkshopScreen()),
      editProfile: (context) => const AuthGuard(child: EditProfileScreen()),
      accountSecurity: (context) => const AuthGuard(child: AccountSecurityScreen()),
      detail: (context) => AuthGuard(
        child: ChangeNotifierProvider(
          create: (_) => DetailPageProvider(),
          child: const DetailScreen(),
        ),
      ),
      myPost: (context) => AuthGuard(
        child: ChangeNotifierProvider(
          create: (_) => MyPostProvider(),
          child: const MyPostScreen(),
        ),
      ),
      favorite: (context) => const AuthGuard(child: FavoriteScreen()),
    };
  }
}
