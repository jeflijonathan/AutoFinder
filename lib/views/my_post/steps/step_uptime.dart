import 'package:autofinder/config/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/views/my_post/provider/edit_workshop_provider.dart';
import 'package:autofinder/services/workshop/operation_time_model.dart';
import 'package:flutter_localization/flutter_localization.dart';

class StepUptime extends StatelessWidget {
  const StepUptime({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditWorkshopProvider>(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Text(
            AppLocale.scheduleTitle.getString(context),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
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
    EditWorkshopProvider provider,
    String day, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(120),
                ),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOpen
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant.withAlpha(150),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                value: isOpen,
                onChanged: (val) => provider.toggleDayOpen(day, val),
                activeThumbColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isOpen
                    ? AppLocale.scheduleOpen.getString(context)
                    : AppLocale.scheduleClosed.getString(context),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOpen
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant.withAlpha(150),
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
                        Text(
                          AppLocale.openingTime.getString(context),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '—',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (day == 'Monday')
                        Text(
                          AppLocale.closingTime.getString(context),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
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
            if (hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.error),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppLocale.scheduleError.getString(context),
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '—',
                    style: TextStyle(color: theme.colorScheme.outlineVariant),
                  ),
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
    EditWorkshopProvider provider,
    String day,
    bool isOpening,
    String currentTime,
  ) async {
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
            SnackBar(
              content: Text(AppLocale.scheduleError.getString(context)),
              backgroundColor: Theme.of(context).colorScheme.error,
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
    final theme = Theme.of(context);

    Color borderColor;
    Color backgroundColor;
    Color textColor;

    if (disabled) {
      borderColor = theme.colorScheme.surfaceContainer;
      backgroundColor = theme.colorScheme.surfaceContainerLow;
      textColor = theme.colorScheme.onSurfaceVariant.withAlpha(100);
    } else if (isError) {
      borderColor = theme.colorScheme.error;
      backgroundColor = theme.colorScheme.errorContainer.withAlpha(80);
      textColor = theme.colorScheme.error;
    } else {
      borderColor = theme.colorScheme.outline;
      backgroundColor = theme.colorScheme.surface;
      textColor = theme.colorScheme.onSurface;
    }

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: TextStyle(
                color: textColor,
                fontWeight: disabled ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            if (!disabled)
              Icon(
                Icons.access_time,
                size: 16,
                color: isError
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
