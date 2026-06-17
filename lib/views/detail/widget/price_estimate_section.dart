import 'package:flutter/material.dart';

class PriceEstimateSection extends StatelessWidget {
  final String? priceEstimate;
  const PriceEstimateSection({super.key, this.priceEstimate});

  @override
  Widget build(BuildContext context) {
    if (priceEstimate == null || priceEstimate!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1B2E20), const Color(0xFF1E293B)]
              : [const Color(0xFFE8F5E9), const Color(0xFFF1F8F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.green.withAlpha(60)
              : Colors.green.withAlpha(80),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(isDark ? 40 : 30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payments_outlined,
              color: isDark ? Colors.green[300] : Colors.green[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimasi Harga',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? Colors.green[300] : Colors.green[700],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priceEstimate!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1B4332),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(isDark ? 50 : 40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Perkiraan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.green[300] : Colors.green[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
