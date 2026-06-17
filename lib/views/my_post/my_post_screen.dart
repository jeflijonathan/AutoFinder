import 'dart:convert';
import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:autofinder/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/views/my_post/provider/my_post_provider.dart';
import 'package:autofinder/views/my_post/controller/my_post_controller.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/views/my_post/widgets/edit_workshop_popup.dart';
import 'package:flutter_localization/flutter_localization.dart';

class MyPostScreen extends StatefulWidget {
  const MyPostScreen({super.key});

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  final MyPostController _myPostController = MyPostController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myPostProvider = context.read<MyPostProvider>();
      final authController = context.read<AuthController>();
      final userId = authController.currentUser?.uid;

      if (userId != null) {
        _myPostController.fetchMyPosts(myPostProvider, userId);
      }
    });
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String workshopId,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocale.deleteTitleConfirmation.getString(context)),
          content: Text(AppLocale.deleteConfirmation.getString(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocale.cancel.getString(context)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                final myPostProvider = context.read<MyPostProvider>();
                _myPostController.deletePost(
                  workshopId,
                  myPostProvider,
                  userId,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocale.deleteLabel.getString(context)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final myPostProvider = context.watch<MyPostProvider>();
    final posts = myPostProvider.state.data;
    final isLoading = myPostProvider.state.isLoading;
    final authController = context.watch<AuthController>();
    final currentUserId = authController.currentUser?.uid ?? "";

    return Scaffold(
      appBar: Navbar(),
      bottomNavigationBar: const ButtonNavBar(currentIndex: -1),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF0F172A),
                        const Color(0xFF1E293B),
                        theme.scaffoldBackgroundColor,
                      ]
                    : [
                        const Color(0xFFF9FAFB),
                        const Color(0xFFF3F4F6),
                        Colors.white,
                      ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocale.titleMyPost.getString(context),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocale.myPostDescription.getString(context),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (posts.isEmpty && !isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'Anda belum memiliki postingan workshop.',
                              style: TextStyle(
                                color: isDark ? Colors.grey : Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final item = posts[index];
                            return _buildPostCard(context, item, currentUserId);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black12,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    WorkshopModel item,
    String currentUserId,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOwner = item.idUser == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: item.image.isNotEmpty
                ? Image.memory(
                    base64Decode(item.image.first.split(',').last),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark ? Colors.grey : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.address,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey : Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (item.priceEstimate != null && item.priceEstimate!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 14,
                              color: isDark ? Colors.green[300] : Colors.green[700],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.priceEstimate!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.green[300] : Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      _buildIconButton(
                        context,
                        icon: Icons.edit_outlined,
                        onTap: () {
                          final myPostProvider = context.read<MyPostProvider>();
                          showEditWorkshopPopup(
                            context,
                            item,
                            myPostProvider,
                            currentUserId,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        context,
                        icon: Icons.delete_outline,
                        onTap: () {
                          _showDeleteConfirmation(
                            context,
                            item.uid ?? "",
                            currentUserId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : const Color(0xFF475569),
        ),
      ),
    );
  }
}
