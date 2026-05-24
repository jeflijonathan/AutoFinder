import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';

class StepVerify extends StatelessWidget {
  const StepVerify({super.key});

  // 1. Amankan pemanggilan asinkronus dengan menyimpan Navigator/ScaffoldMessenger State di awal
  // atau pastikan validasi context dilakukan dengan ketat.
  Future<void> _pickImage(
    BuildContext context,
    AddWorkshopProvider provider,
  ) async {
    // Validasi awal SEBELUM masuk ke proses async picker
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
      imageQuality: 85,
    );

    // 2. WAJIB periksa apakah widget masih aktif di screen setelah menunggu user memilih foto
    if (!context.mounted) return;

    if (file != null) {
      if (provider.images.length >= 4) {
        _showWarningSnackBar(
          context,
          'Maksimal 4 foto. Hapus foto yang ada untuk menambah yang baru.',
        );
        return;
      }
      provider.addImage(file.path);
    }
  }

  // Fungsi helper untuk memisahkan logika SnackBar agar kode lebih bersih
  void _showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar(); // Hapus snackbar lama jika ada
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan context.watch agar widget merefresh ketika provider berubah
    final provider = context.watch<AddWorkshopProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documentation',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload high-resolution images of your facility.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        // Photo counter
        Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 16,
              color: provider.images.length >= 4
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF0052CC),
            ),
            const SizedBox(width: 6),
            Text(
              '${provider.images.length}/4 foto',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: provider.images.length >= 4
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF0052CC),
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
              // List uploaded images
              ...List.generate(provider.images.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      // Image preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(provider.images[index]),
                          height: 150,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Photo Index Label
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
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
                      // Delete Button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => provider.removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Upload button (only if < 4 images)
              if (provider.images.length < 4)
                InkWell(
                  onTap: () => _pickImage(context, provider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 150,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0052CC),
                        width: 2,
                      ),
                      color: const Color(0xFFF0F4FF),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Color(0xFF0052CC),
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ADD PHOTO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0052CC),
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
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
      ],
    );
  }
}
