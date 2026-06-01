import 'dart:convert';
import 'package:autofinder/services/users/users_service.dart';
import 'package:autofinder/services/workshop/commentar_model.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/views/detail/controller/detail_controller.dart';
import 'package:autofinder/views/detail/provider/detail_page_provider.dart';
import 'package:autofinder/widgets/dialogs/base_dialog.dart';
import 'package:autofinder/widgets/dialogs/content_dialog.dart';
import 'package:autofinder/widgets/dialogs/header_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Tambahkan import lokalisasi Anda
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

ImageProvider? _getProfileImage(String? imageString) {
  if (imageString == null || imageString.trim().isEmpty) return null;
  try {
    if (imageString.startsWith('http')) {
      return NetworkImage(imageString);
    } else {
      String base64Str = imageString;
      if (imageString.contains('base64,')) {
        base64Str = imageString.split('base64,').last;
      }
      return MemoryImage(base64Decode(base64Str));
    }
  } catch (e) {
    return null;
  }
}

class ReviewsSection extends StatelessWidget {
  final DetailPageProvider provider;
  final DetailController controller;
  final String workshopId;

  const ReviewsSection({
    super.key,
    required this.provider,
    required this.controller,
    required this.workshopId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = provider.state;

    final currentUser = context.watch<AuthController>().currentUser;
    final userId = currentUser?.uid ?? '';

    final alreadyReviewed =
        userId.isNotEmpty && state.comments.any((c) => c.userId == userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocale.clientReviews.getString(
                context,
              ), // "Client Reviews" Terlokalisasi
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (alreadyReviewed)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  AppLocale.alreadyReviewed.getString(
                    context,
                  ), // "Sudah diulas ✓" Terlokalisasi
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: userId.isEmpty
                    ? null
                    : () => _showAddCommentDialog(context, userId),
                child: Text(
                  AppLocale.writeReview.getString(
                    context,
                  ), // "Tulis Ulasan" Terlokalisasi
                  style: TextStyle(
                    color: userId.isEmpty ? Colors.grey : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocale.noReviewsYet.getString(context),
              ), // "Belum ada ulasan..." Terlokalisasi
            ),
          )
        else
          ...state.comments.map(
            (comment) =>
                _buildReviewCard(context, comment, isDark, userId),
          ),
      ],
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    CommentarModel comment,
    bool isDark,
    String currentUserId,
  ) {
    final isOwner = currentUserId.isNotEmpty && comment.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FutureBuilder(
        future: UsersService().getDataById('users', comment.userId),
        builder: (context, snapshot) {
          String displayName = 'Unknown User';
          String? displayProfileUrl;

          if (snapshot.hasData && snapshot.data?.status == "success") {
            final userData = snapshot.data!.data;
            if (userData != null) {
              displayName = userData['username'] ?? displayName;
              displayProfileUrl = userData['profilePictureUrl'] ?? displayProfileUrl;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: isDark ? Colors.grey : Colors.white,
                    backgroundImage: _getProfileImage(displayProfileUrl),
                    child: _getProfileImage(displayProfileUrl) == null
                        ? Icon(
                            Icons.person,
                            color: isDark ? Colors.white54 : Colors.black54,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppLocale.customerLabel.getString(
                            context,
                          ), // "Pelanggan" Terlokalisasi
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < comment.rating ? Icons.star : Icons.star_border,
                    color: Colors.orange.shade600,
                    size: 16,
                  );
                }),
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.grey : Colors.grey,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditCommentDialog(context, comment);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, comment.uid!);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(
                            AppLocale.editLabel.getString(context),
                          ), // "Edit" Terlokalisasi
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            AppLocale.deleteLabel.getString(
                              context,
                            ), // "Hapus" Terlokalisasi
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: AppLocale.translateLive(comment.description),
            builder: (context, snapshot) {
              final translatedText = snapshot.data ?? comment.description;
              return Text(
                '"$translatedText"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey : Colors.grey,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          if (currentUserId.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => _showReplyDialog(
                  context,
                  comment.uid!,
                  currentUserId,
                ),
                child: Text(
                  AppLocale.replyLabel.getString(context),
                  style: TextStyle(
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comment.replies.map((r) {
                  final replyMap = r as Map<String, dynamic>;
                  return FutureBuilder(
                    future: UsersService().getDataById('users', replyMap['userId'] ?? ''),
                    builder: (context, snapshot) {
                      String displayName = replyMap['userName'] ?? 'Unknown';
                      String? displayProfileUrl;

                      if (snapshot.hasData && snapshot.data?.status == "success") {
                        final userData = snapshot.data!.data;
                        if (userData != null) {
                          displayName = userData['username'] ?? displayName;
                          displayProfileUrl = userData['profilePictureUrl'];
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isDark ? Colors.grey : Colors.white,
                              backgroundImage: _getProfileImage(displayProfileUrl),
                              child: _getProfileImage(displayProfileUrl) == null
                                  ? Icon(
                                      Icons.person,
                                      size: 16,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  FutureBuilder<String>(
                                    future: AppLocale.translateLive(
                                      replyMap['text'] ?? '',
                                    ),
                                    builder: (context, translationSnapshot) {
                                      final translatedReply =
                                          translationSnapshot.data ?? replyMap['text'] ?? '';
                                      return Text(
                                        translatedReply,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(height: 1.4),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.grey : Colors.grey),
        ],
      );
    },
  ),
);
}

  void _showDeleteDialog(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocale.deleteReviewTitle.getString(context)),
          content: Text(AppLocale.deleteReviewContent.getString(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocale.cancelLabel.getString(context)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteComment(provider, workshopId, commentId);
              },
              child: Text(
                AppLocale.deleteLabel.getString(context),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCommentDialog(
    BuildContext context,
    String userId,
  ) {
    int selectedRating = 5;
    final textController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return BaseDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderDialog(
                    title: AppLocale.writeReview.getString(context),
                    icon: Icons.rate_review_outlined,
                  ),
                  ContentDialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocale.rateExperienceInstruction.getString(
                            context,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.orange.shade600,
                                size: 32,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedRating = index + 1;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: textController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: AppLocale.reviewFieldHint.getString(
                                context,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (textController.text.trim().isEmpty)
                                      return;
                                    setState(() => isSubmitting = true);

                                    await controller.submitComment(
                                      provider,
                                      workshopId,
                                      userId,
                                      selectedRating,
                                      textController.text.trim(),
                                    );

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              disabledBackgroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocale.submitReview.getString(context),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditCommentDialog(BuildContext context, CommentarModel comment) {
    int selectedRating = comment.rating;
    final textController = TextEditingController(text: comment.description);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return BaseDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderDialog(
                    title: AppLocale.editReviewTitle.getString(context),
                    icon: Icons.edit_note,
                  ),
                  ContentDialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocale.updateExperienceInstruction.getString(
                            context,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.orange.shade600,
                                size: 32,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedRating = index + 1;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: textController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: AppLocale.reviewFieldHint.getString(
                                context,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (textController.text.trim().isEmpty)
                                      return;
                                    setState(() => isSubmitting = true);

                                    await controller.editComment(
                                      provider,
                                      workshopId,
                                      comment.uid!,
                                      selectedRating,
                                      textController.text.trim(),
                                    );

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              disabledBackgroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocale.saveChanges.getString(context),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReplyDialog(
    BuildContext context,
    String commentId,
    String userId,
  ) {
    final textController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return BaseDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderDialog(
                    title: AppLocale.replyReviewTitle.getString(context),
                    icon: Icons.reply,
                  ),
                  ContentDialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: textController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: AppLocale.replyFieldHint.getString(
                                context,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (textController.text.trim().isEmpty)
                                      return;
                                    setState(() => isSubmitting = true);

                                    await controller.replyToComment(
                                      provider,
                                      workshopId,
                                      commentId,
                                      userId,
                                      textController.text.trim(),
                                    );

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              disabledBackgroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocale.sendReply.getString(context),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
