import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/config/app_locale.dart'; // 🟢 Import file lokal Anda
import 'package:flutter_localization/flutter_localization.dart'; // 🟢 Import package localization

class Loading extends StatelessWidget {
  final double size;
  final String?
  message; // 🟢 Menggunakan String? agar bisa otomatis fallback ke locale jika kosong
  final bool showMessage;
  final bool asOverlay;

  const Loading({
    super.key,
    this.size = 160,
    this.message, // 🟢 Kosongkan nilai default agar dibaca secara dinamis saat build
    this.showMessage = true,
    this.asOverlay = false,
  });

  Widget _content(BuildContext context) {
    // 🟢 Ambil string secara dinamis berdasarkan locale aktif saat ini
    final String displayMessage =
        message ?? AppLocale.loadingMessage.getString(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'json/Cute_Mascot_Jumping_Character.json',
          width: size,
          height: size,
          fit: BoxFit.contain,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Lottie load error: $error');
            return const Icon(Icons.error, color: Colors.red, size: 60);
          },
        ),
        if (showMessage) ...[
          const SizedBox(height: 12),
          Text(
            displayMessage,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (asOverlay) {
      return Container(
        color: Colors.black.withOpacity(0.35),
        child: Center(child: _content(context)), // 🟢 Oper context ke _content
      );
    }
    return Center(child: _content(context)); // 🟢 Oper context ke _content
  }
}

class LoadingOverlay {
  static OverlayEntry? _entry;

  static VoidCallback show(
    BuildContext context, {
    String?
    message, // 🟢 Menggunakan String? agar fleksibel mengikuti bahasa daerah/negara aktif
    double size = 160,
  }) {
    // 🟢 Deteksi locale menggunakan context yang dikirimkan oleh screen pengeksekusi
    final String displayMessage =
        message ?? AppLocale.loadingMessage.getString(context);

    _entry = OverlayEntry(
      builder: (_) =>
          Loading(size: size, message: displayMessage, asOverlay: true),
    );
    Overlay.of(context).insert(_entry!);

    return () {
      _entry?.remove();
      _entry = null;
    };
  }
}
