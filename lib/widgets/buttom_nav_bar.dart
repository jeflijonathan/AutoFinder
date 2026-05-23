import 'package:autofinder/config/app_routes.dart';
import 'package:flutter/material.dart';

class ButtonNavBar extends StatelessWidget {
  final int currentIndex;

  const ButtonNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        if (currentIndex == index) return;

        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
            break;
        }
      },
    );
  }
}
