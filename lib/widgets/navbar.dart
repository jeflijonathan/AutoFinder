import 'dart:convert';
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/config/app_routes.dart';
import 'package:flutter_localization/flutter_localization.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final username = user?.username ?? 'U';

    final theme = Theme.of(context);

    final imageUrl =
        (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty)
        ? user.profilePictureUrl!
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=0D8ABC&color=fff';

    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Auto Finder',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'my_post') {
                Navigator.pushNamed(context, AppRoutes.myPost);
              } else if (value == 'logout') {
                authController.handleLogoutRequest(context: context);
              }
            },
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'my_post',
                child: Row(
                  children: [
                    Icon(Icons.post_add, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 8),
                    Text(AppLocale.titleMyPost.getString(context)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      AppLocale.logout.getString(context),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                        );
                      },
                    )
                  : Image.memory(
                      base64Decode(imageUrl),
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: theme.colorScheme.onSurfaceVariant,
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
