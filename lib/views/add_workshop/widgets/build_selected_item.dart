import 'package:flutter/material.dart';

class BuildSelectedItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onRemove;

  const BuildSelectedItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onRemove,
  });

  @override
  State<BuildSelectedItem> createState() => _BuildSelectedItemState();
}

class _BuildSelectedItemState extends State<BuildSelectedItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; // Warna biru utama dinamis

    return Container(
      decoration: BoxDecoration(
        // Background transparan tipis adaptif (~8%)
        color: primaryColor.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 28, color: primaryColor),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Badge Tombol Hapus (×) di pojok kanan atas
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: widget.onRemove,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  // Tetap menggunakan warna merah statis/error theme untuk indikator hapus yang tegas
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors
                      .white, // Ikon silang tetap putih agar kontras di atas warna merah
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
