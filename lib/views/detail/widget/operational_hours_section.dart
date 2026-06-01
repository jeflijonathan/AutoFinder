import 'package:autofinder/services/workshop/operation_time_model.dart';
import 'package:autofinder/widgets/dialogs/base_dialog.dart';
import 'package:autofinder/widgets/dialogs/content_dialog.dart';
import 'package:autofinder/widgets/dialogs/header_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import modul lokalisasi aplikasi Anda
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

class OperationalHoursSection extends StatelessWidget {
  final List<OperationTimeModel>? operationTimes;

  const OperationalHoursSection({super.key, this.operationTimes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();

    // Mendapatkan kode bahasa yang aktif saat ini (en, id, ja, zh, atau th)
    final String currentLangCode =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';

    // Mengonversi hari ini ke format nama hari penuh sesuai bahasa aktif aplikasi
    final String todayNameFormatted = DateFormat(
      'EEEE',
      currentLangCode,
    ).format(now);

    // Fallback nama hari mentah untuk mencocokkan data database/API (antisipasi jika data API berupa teks Inggris atau Indo)
    final String todayEnglish = DateFormat(
      'EEEE',
      'en',
    ).format(now).toLowerCase();
    final String todayIndonesian = DateFormat(
      'EEEE',
      'id',
    ).format(now).toLowerCase();

    OperationTimeModel? todaySchedule;
    if (operationTimes != null) {
      try {
        todaySchedule = operationTimes!.firstWhere((element) {
          final dayRaw = element.day.trim().toLowerCase();
          return dayRaw == todayEnglish || dayRaw == todayIndonesian;
        });
      } catch (e) {
        todaySchedule = null;
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
                AppLocale.oprationalHours.getString(context),
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
                  isOpen
                      ? AppLocale.scheduleOpen.getString(context)
                      : AppLocale.scheduleClosed.getString(context),
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
                // Menampilkan nama hari yang otomatis diterjemahkan oleh DateFormat
                todayNameFormatted.isNotEmpty
                    ? todayNameFormatted.toUpperCase() +
                          todayNameFormatted.substring(1)
                    : todayNameFormatted,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              Text(
                todaySchedule != null &&
                        todaySchedule.openTime.isNotEmpty &&
                        todaySchedule.openTime.toLowerCase() != 'tutup' &&
                        todaySchedule.openTime.toLowerCase() != 'closed'
                    ? '${todaySchedule.openTime} - ${todaySchedule.closeTime}'
                    : AppLocale.scheduleClosed.getString(context),
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
              onTap: () => _showScheduleDialog(
                context,
                todayEnglish,
                todayIndonesian,
                currentLangCode,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  AppLocale.viewAll.getString(context),
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
        schedule.openTime.toLowerCase() == 'tutup' ||
        schedule.openTime.toLowerCase() == 'closed') {
      return false;
    }

    try {
      final now = DateTime.now();
      final cleanOpenTime = schedule.openTime.trim();
      final cleanCloseTime = schedule.closeTime.trim();

      final bool is12HourFormat =
          cleanOpenTime.toLowerCase().contains('am') ||
          cleanOpenTime.toLowerCase().contains('pm');

      final DateFormat format = is12HourFormat
          ? DateFormat("hh:mm a")
          : DateFormat("HH:mm");

      final openTime = format.parse(cleanOpenTime);
      final closeTime = format.parse(cleanCloseTime);

      final currentMinutes = (now.hour * 60) + now.minute;
      final openMinutes = (openTime.hour * 60) + openTime.minute;
      final closeMinutes = (closeTime.hour * 60) + closeTime.minute;

      if (closeMinutes < openMinutes) {
        return currentMinutes >= openMinutes || currentMinutes < closeMinutes;
      }

      return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
    } catch (e) {
      return false;
    }
  }

  void _showScheduleDialog(
    BuildContext context,
    String todayEnglish,
    String todayIndonesian,
    String currentLangCode,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return BaseDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeaderDialog(
                title: AppLocale.oprationalHours.getString(context),
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
                          final String currentDayStr = schedule.day
                              .trim()
                              .toLowerCase();
                          final isToday =
                              currentDayStr == todayEnglish ||
                              currentDayStr == todayIndonesian;
                          final isClosed =
                              schedule.openTime.isEmpty ||
                              schedule.openTime.toLowerCase() == 'tutup' ||
                              schedule.openTime.toLowerCase() == 'closed';

                          // Mengonversi teks string nama hari dari API agar tampil sesuai bahasa aktif user
                          String displayDay = schedule.day.toUpperCase().trim();
                          try {
                            final tempDays = [
                              'monday',
                              'tuesday',
                              'wednesday',
                              'thursday',
                              'friday',
                              'saturday',
                              'sunday',
                            ];
                            final tempIndex = tempDays.indexOf(currentDayStr);
                            if (tempIndex != -1) {
                              // Mengambil index tanggal yang tepat untuk simulasi nama hari
                              final tempDate = DateTime(2026, 6, tempIndex + 1);
                              displayDay = DateFormat(
                                'EEEE',
                                currentLangCode,
                              ).format(tempDate).toUpperCase();
                            }
                          } catch (_) {}

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
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  displayDay,
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
                                      color: theme.primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '•', // Menggunakan simbol dot penanda hari aktif agar netral dari bias bahasa/kata
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
                                      ? AppLocale.scheduleClosed.getString(
                                          context,
                                        )
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
