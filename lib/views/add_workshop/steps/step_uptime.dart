import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';
import 'package:autofinder/services/workshop/operation_time_model.dart';

class StepUptime extends StatelessWidget {
  const StepUptime({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddWorkshopProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: const Text(
            'WEEKLY SCHEDULE CONFIGURATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
        _buildDayRow(context, provider, 'Monday'),
        _buildDayRow(context, provider, 'Tuesday'),
        _buildDayRow(context, provider, 'Wednesday'),
        _buildDayRow(context, provider, 'Thursday'),
        _buildDayRow(context, provider, 'Friday'),
        _buildDayRow(context, provider, 'Saturday'),
        _buildDayRow(context, provider, 'Sunday', isLast: true),
      ],
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    AddWorkshopProvider provider,
    String day, {
    bool isLast = false,
  }) {
    final isOpen = provider.isOpen[day] ?? false;
    final invalidDays = provider.getInvalidUptimeDays();
    final bool hasError = isOpen && invalidDays.contains(day);

    final timeModel = provider.activeOperationTimes.firstWhere(
      (element) => element.day == day,
      orElse: () => OperationTimeModel(
        day: day,
        openTime: '08:00 AM',
        closeTime: '05:00 PM',
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOpen ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                value: isOpen,
                onChanged: (val) => provider.toggleDayOpen(day, val),
                activeTrackColor: const Color(0xFF0052CC),
              ),
              const SizedBox(width: 8),
              Text(
                isOpen ? 'OPEN' : 'CLOSED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOpen
                      ? const Color(0xFF4B5563)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          if (isOpen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (day == 'Monday')
                        const Text(
                          'OPENING TIME',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      const SizedBox(height: 4),
                      _buildTimeInput(
                        context,
                        timeModel.openTime,
                        isError: hasError,
                        onTap: () => _selectTime(
                          context,
                          provider,
                          day,
                          true,
                          timeModel.openTime,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('—', style: TextStyle(color: Color(0xFF9CA3AF))),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (day == 'Monday')
                        const Text(
                          'CLOSING TIME',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      const SizedBox(height: 4),
                      _buildTimeInput(
                        context,
                        timeModel.closeTime,
                        isError: hasError,
                        onTap: () => _selectTime(
                          context,
                          provider,
                          day,
                          false,
                          timeModel.closeTime,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Inline error message
            if (hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Jam buka harus lebih awal dari jam tutup!',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeInput(context, '--:-- --', disabled: true),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('—', style: TextStyle(color: Color(0xFFE5E7EB))),
                ),
                Expanded(
                  child: _buildTimeInput(context, '--:-- --', disabled: true),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    AddWorkshopProvider provider,
    String day,
    bool isOpening,
    String currentTime,
  ) async {
    // Parse current time string (e.g. "08:00 AM")
    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);
    try {
      if (currentTime != '--:-- --') {
        final parts = currentTime.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final int minute = int.parse(timeParts[1]);
        if (parts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
        if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
        initialTime = TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (context.mounted) {
        // Validation logic
        final timeModel = provider.activeOperationTimes.firstWhere(
          (element) => element.day == day,
          orElse: () => OperationTimeModel(
            day: day,
            openTime: '08:00 AM',
            closeTime: '05:00 PM',
          ),
        );

        String otherTimeString = isOpening
            ? timeModel.closeTime
            : timeModel.openTime;
        TimeOfDay otherTime = const TimeOfDay(hour: 0, minute: 0);
        try {
          final parts = otherTimeString.split(' ');
          final timeParts = parts[0].split(':');
          int hour = int.parse(timeParts[0]);
          final int minute = int.parse(timeParts[1]);
          if (parts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
          if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
          otherTime = TimeOfDay(hour: hour, minute: minute);
        } catch (_) {}

        final double pickedVal = picked.hour + picked.minute / 60.0;
        final double otherVal = otherTime.hour + otherTime.minute / 60.0;

        bool isValid = true;
        if (isOpening && pickedVal >= otherVal) {
          isValid = false;
        } else if (!isOpening && pickedVal <= otherVal) {
          isValid = false;
        }

        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jam buka harus lebih awal dari jam tutup!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final localizations = MaterialLocalizations.of(context);
        final formattedTime = localizations.formatTimeOfDay(
          picked,
          alwaysUse24HourFormat: false,
        );
        provider.updateOperationTime(day, isOpening, formattedTime);
      }
    }
  }

  Widget _buildTimeInput(
    BuildContext context,
    String time, {
    bool disabled = false,
    bool isError = false,
    VoidCallback? onTap,
  }) {
    Color borderColor;
    if (disabled) {
      borderColor = const Color(0xFFF3F4F6);
    } else if (isError) {
      borderColor = const Color(0xFFEF4444);
    } else {
      borderColor = const Color(0xFFD1D5DB);
    }

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFF9FAFB)
              : (isError ? const Color(0xFFFEF2F2) : Colors.white),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: TextStyle(
                color: disabled
                    ? const Color(0xFFD1D5DB)
                    : (isError
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF1F2937)),
              ),
            ),
            if (!disabled)
              Icon(
                Icons.access_time,
                size: 16,
                color: isError
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }
}
