import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:autofinder/config/app_colors.dart';

class Loading extends StatelessWidget {
  final double size;
  final String message;
  final bool showMessage;
  final bool asOverlay;

  const Loading({
    super.key,
    this.size = 160,
    this.message = 'Mohon tunggu...',
    this.showMessage = true,
    this.asOverlay = false,
  });

  Widget _content() {
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
            message,
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
        child: Center(child: _content()),
      );
    }
    return Center(child: _content());
  }
}

class LoadingOverlay {
  static OverlayEntry? _entry;

  static VoidCallback show(
    BuildContext context, {
    String message = 'Mohon tunggu...',
    double size = 160,
  }) {
    _entry = OverlayEntry(
      builder: (_) => Loading(size: size, message: message, asOverlay: true),
    );
    Overlay.of(context).insert(_entry!);

    return () {
      _entry?.remove();
      _entry = null;
    };
  }
}
