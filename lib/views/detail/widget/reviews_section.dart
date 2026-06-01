import 'package:autofinder/services/workshop/commentar_model.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/views/detail/controller/detail_controller.dart';
import 'package:autofinder/views/detail/provider/detail_page_provider.dart';
import 'package:autofinder/widgets/dialogs/base_dialog.dart';
import 'package:autofinder/widgets/dialogs/content_dialog.dart';
import 'package:autofinder/widgets/dialogs/header_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final userName = currentUser?.username ?? 'Unknown User';

    final alreadyReviewed =
        userId.isNotEmpty && state.comments.any((c) => c.userId == userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Client Reviews',
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
                  'Sudah diulas ✓',
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
                    : () => _showAddCommentDialog(context, userId, userName),
                child: Text(
                  'Tulis Ulasan',
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
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Belum ada ulasan. Jadilah yang pertama!'),
            ),
          )
        else
          ...state.comments.map(
            (comment) =>
                _buildReviewCard(context, comment, isDark, userId, userName),
          ),
      ],
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    CommentarModel comment,
    bool isDark,
    String currentUserId,
    String currentUserName,
  ) {
    final isOwner = currentUserId.isNotEmpty && comment.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                child: Icon(
                  Icons.person,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pelanggan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${comment.description}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[300] : Colors.grey[800],
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // Balas Button
          if (currentUserId.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => _showReplyDialog(
                  context,
                  comment.uid!,
                  currentUserId,
                  currentUserName,
                ),
                child: Text(
                  'Balas',
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
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          replyMap['userName'] ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          replyMap['text'] ?? '',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Ulasan?'),
          content: const Text('Ulasan yang dihapus tidak dapat dikembalikan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteComment(provider, workshopId, commentId);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddCommentDialog(
    BuildContext context,
    String userId,
    String userName,
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
                  const HeaderDialog(
                    title: 'Tulis Ulasan',
                    icon: Icons.rate_review_outlined,
                  ),
                  ContentDialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Beri penilaian pengalaman Anda'),
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
                              hintText:
                                  'Ceritakan pengalaman Anda di bengkel ini...',
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey[100],
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
                                      userName,
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
                                : const Text(
                                    'Kirim Ulasan',
                                    style: TextStyle(
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
                  const HeaderDialog(
                    title: 'Edit Ulasan',
                    icon: Icons.edit_note,
                  ),
                  ContentDialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Perbarui penilaian Anda'),
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
                              hintText:
                                  'Ceritakan pengalaman Anda di bengkel ini...',
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey[100],
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
                                : const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
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
    String userName,
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
                  const HeaderDialog(title: 'Balas Ulasan', icon: Icons.reply),
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
                              hintText: 'Ketik balasan Anda...',
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey[100],
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
                                      userName,
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
                                : const Text(
                                    'Kirim Balasan',
                                    style: TextStyle(
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
