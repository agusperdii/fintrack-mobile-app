import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';

class AppDateTimePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
    String title = 'Pilih Waktu',
  }) async {
    DateTime? selectedDate = initialDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: SavaioTheme.surfaceContainer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SavaioTheme.outlineVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppHeading(title, size: AppHeadingSize.h3),
            const SizedBox(height: 24),
            
            // The Picker
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: SavaioTheme.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: initialDate,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            AppButton(
              label: 'KONFIRMASI',
              onTap: () => Navigator.pop(context, selectedDate),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Future<String?> showMonthPicker({
    required BuildContext context,
    required String initialMonth, // Format: YYYY-MM
  }) async {
    final now = DateTime.now();
    final parts = initialMonth.split('-');
    DateTime initialDate = DateTime(
      int.tryParse(parts[0]) ?? now.year,
      int.tryParse(parts[1]) ?? now.month,
    );
    
    DateTime? picked = await show(
      context: context,
      initialDate: initialDate,
      mode: CupertinoDatePickerMode.monthYear,
      title: 'Pilih Bulan',
    );

    if (picked != null) {
      return "${picked.year}-${picked.month.toString().padLeft(2, '0')}";
    }
    return null;
  }
}
