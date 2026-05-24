import 'package:flutter/material.dart';

class BuildSelectedItem extends StatefulWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final VoidCallback onRemove;

  const BuildSelectedItem({
    super.key,
    required this.context,
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0052CC).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0052CC), width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 28, color: const Color(0xFF0052CC)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0052CC),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Remove (×) badge
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D4F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
    ;
  }
}
