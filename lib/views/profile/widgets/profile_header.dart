import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:autofinder/config/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String profilePic;
  final VoidCallback onEditProfilePic;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    required this.profilePic,
    required this.onEditProfilePic,
  });

  Widget _buildProfileImage() {
    if (profilePic.isEmpty) {
      return const Image(
        image: AssetImage('images/default-avatar.jpg'),
        fit: BoxFit.cover,
      );
    }

    if (profilePic.startsWith('http')) {
      return Image.network(
        profilePic,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Image(
          image: AssetImage('images/default-avatar.jpg'),
          fit: BoxFit.cover,
        ),
      );
    } else {
      try {
        final bytes = base64Decode(profilePic);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Image(
            image: AssetImage('images/default-avatar.jpg'),
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        return const Image(
          image: AssetImage('images/default-avatar.jpg'),
          fit: BoxFit.cover,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildProfileImage(),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: InkWell(
                onTap: onEditProfilePic,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
