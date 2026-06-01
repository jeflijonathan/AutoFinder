import 'package:autofinder/services/workshop/operation_time_model.dart';
import 'package:autofinder/widgets/dialogs/base_dialog.dart';
import 'package:autofinder/widgets/dialogs/content_dialog.dart';
import 'package:autofinder/widgets/dialogs/header_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OperationalHoursSection extends StatelessWidget {
  final List<OperationTimeModel>? operationTimes;

  const OperationalHoursSection({super.key, this.operationTimes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();

    // Sesuaikan nama hari dengan format yang dikembalikan oleh API Anda.
    // Jika API mengembalikan bahasa Inggris (MONDAY, TUESDAY), ubah isi array ini ke bahasa Inggris.
    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    final todayName = dayNames[now.weekday - 1];

    OperationTimeModel? todaySchedule;
    if (operationTimes != null) {
      try {
        todaySchedule = operationTimes!.firstWhere(
          (element) =>
              element.day.trim().toLowerCase() == todayName.toLowerCase(),
        );
      } catch (e) {
        // Jika tidak ketemu berdasarkan bahasa Indonesia, mari coba fallback pencarian ke bahasa Inggris
        try {
          final englishDays = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday',
          ];
          final todayEnglish = englishDays[now.weekday - 1];
          todaySchedule = operationTimes!.firstWhere(
            (element) => element.day.trim().toLowerCase() == todayEnglish,
          );
        } catch (_) {
          todaySchedule = null;
        }
      }
    }

    final isOpen = _checkIsOpen(todaySchedule);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Operational Hours',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOpen ? 'Open' : 'Closed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                todayName,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              Text(
                todaySchedule != null &&
                        todaySchedule.openTime.isNotEmpty &&
                        todaySchedule.openTime.toLowerCase() != 'tutup'
                    ? '${todaySchedule.openTime} - ${todaySchedule.closeTime}'
                    : 'Tutup',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _showScheduleDialog(context, todayName),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey! : Colors.grey!,
                  ),
                ),
                child: Text(
                  'view more...',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _checkIsOpen(OperationTimeModel? schedule) {
    if (schedule == null ||
        schedule.openTime.isEmpty ||
        schedule.openTime.toLowerCase() == 'tutup') {
      return false;
    }

    try {
      final now = DateTime.now();

      final cleanOpenTime = schedule.openTime.trim();
      final cleanCloseTime = schedule.closeTime.trim();

      // Mendeteksi apakah data dari API mengandung teks AM atau PM
      final bool is12HourFormat =
          cleanOpenTime.toLowerCase().contains('am') ||
          cleanOpenTime.toLowerCase().contains('pm');

      // Menggunakan pola "hh:mm a" jika terdeteksi format 12 jam (AM/PM)
      final DateFormat format = is12HourFormat
          ? DateFormat("hh:mm a")
          : DateFormat("HH:mm");

      final openTime = format.parse(cleanOpenTime);
      final closeTime = format.parse(cleanCloseTime);

      // Konversi semua waktu ke total menit sejak tengah malam (00:00)
      final currentMinutes = (now.hour * 60) + now.minute;
      final openMinutes = (openTime.hour * 60) + openTime.minute;
      final closeMinutes = (closeTime.hour * 60) + closeTime.minute;

      // Antisipasi jika ada jadwal operasional melewati tengah malam (misal 17:00 - 02:00)
      if (closeMinutes < openMinutes) {
        return currentMinutes >= openMinutes || currentMinutes < closeMinutes;
      }

      // Kondisi normal (misal 08:00 AM hingga 05:00 PM)
      return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
    } catch (e) {
      return false;
    }
  }

  void _showScheduleDialog(BuildContext context, String todayName) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return BaseDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HeaderDialog(
                title: 'Operational Hours',
                icon: Icons.access_time_rounded,
              ),
              ContentDialog(
                child: operationTimes == null || operationTimes!.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No schedule available"),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: operationTimes!.map((schedule) {
                          // Pencarian kecocokan hari ini di dalam Dialog (Mendukung Indo & Inggris)
                          final String currentDayStr = schedule.day
                              .trim()
                              .toLowerCase();
                          final englishDays = [
                            'monday',
                            'tuesday',
                            'wednesday',
                            'thursday',
                            'friday',
                            'saturday',
                            'sunday',
                          ];
                          final todayEnglish =
                              englishDays[DateTime.now().weekday - 1];

                          final isToday =
                              currentDayStr == todayName.toLowerCase() ||
                              currentDayStr == todayEnglish;

                          final isClosed =
                              schedule.openTime.isEmpty ||
                              schedule.openTime.toLowerCase() == 'tutup';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isClosed
                                  ? (isDark
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.red.shade50)
                                  : (isDark
                                        ? const Color(0xFF2C394F)
                                        : Colors.grey.shade50),
                              border: Border.all(
                                color: isClosed
                                    ? Colors.red.shade200
                                    : (isDark
                                          ? Colors.grey!
                                          : Colors.grey.shade300),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  schedule.day.toUpperCase().trim(),
                                  style: TextStyle(
                                    color: isClosed
                                        ? Colors.red
                                        : (isDark ? Colors.grey : Colors.grey),
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isToday) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'HARI INI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  isClosed
                                      ? 'Tutup'
                                      : '${schedule.openTime} - ${schedule.closeTime}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isClosed
                                        ? Colors.red
                                        : (isDark
                                              ? Colors.white
                                              : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
