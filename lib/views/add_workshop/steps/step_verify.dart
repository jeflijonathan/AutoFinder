import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';

class StepVerify extends StatelessWidget {
  const StepVerify({super.key});

  Future<void> _pickImage(
    BuildContext context,
    AddWorkshopProvider provider,
  ) async {
    if (provider.images.length >= 4) {
      _showWarningSnackBar(
        context,
        'Maksimal 4 foto. Hapus foto yang ada untuk menambah yang baru.',
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 600,
      maxHeight: 600,
    );

    if (!context.mounted) return;

    if (file != null) {
      if (provider.images.length >= 4) {
        _showWarningSnackBar(
          context,
          'Maksimal 4 foto. Hapus foto yang ada untuk menambah yang baru.',
        );
        return;
      }
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      provider.addImage(base64Image);
    }
  }

  void _showWarningSnackBar(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
        ),
        backgroundColor: theme.colorScheme.errorContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddWorkshopProvider>();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isMaxImages = provider.images.length >= 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documentation',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload high-resolution images of your facility.',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 16,
              color: isMaxImages
                  ? theme.colorScheme.onSurfaceVariant
                  : primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              '${provider.images.length}/4 foto',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isMaxImages
                    ? theme.colorScheme.onSurfaceVariant
                    : primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(provider.images.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(provider.images[index]),
                          height: 150,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => provider.removeImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cancel,
                              color: theme.colorScheme.error,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              if (!isMaxImages)
                InkWell(
                  onTap: () => _pickImage(context, provider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 150,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor, width: 2),
                      color: primaryColor.withAlpha(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: primaryColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ADD PHOTO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (provider.images.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Belum ada foto yang diunggah.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
              ),
            ),
          ),
      ],
    );
  }
}
