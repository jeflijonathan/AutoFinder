import 'package:flutter/material.dart';
import 'package:autofinder/config/app_colors.dart';

enum ImageSourceType { camera, gallery }

class ImageSourceSheet {
  static void show({
    required BuildContext context,
    required Function(ImageSourceType) onSourceSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                    color: AppColors.primary,
                  ),
                  title: const Text('Ambil Foto via Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSourceType.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSourceType.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
