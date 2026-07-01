import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;

  const CustomDatePickerDialog({
    super.key, 
    required this.initialDate,
    this.minDate,
    this.maxDate,
  });

  static Future<DateTime?> show(
    BuildContext context, 
    DateTime initialDate, {
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => CustomDatePickerDialog(
        initialDate: initialDate,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );
  }

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;

  late final int baseYear;
  late final int maxYearCount;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  final List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.minDate != null) {
      baseYear = widget.minDate!.year;
    } else {
      baseYear = DateTime.now().year;
    }

    if (widget.maxDate != null) {
      maxYearCount = widget.maxDate!.year - baseYear + 1;
      if (maxYearCount < 1) maxYearCount = 1;
    } else {
      maxYearCount = 100;
    }

    DateTime initDate = widget.initialDate;
    
    if (widget.minDate != null && initDate.isBefore(widget.minDate!)) {
      initDate = widget.minDate!;
    } else if (widget.maxDate != null && initDate.isAfter(widget.maxDate!)) {
      initDate = widget.maxDate!;
    }

    selectedDay = initDate.day;
    selectedMonth = initDate.month;
    selectedYear = initDate.year;

    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    _yearController = FixedExtentScrollController(initialItem: selectedYear - baseYear);
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _enforceConstraints() {
    DateTime selected = DateTime(selectedYear, selectedMonth, selectedDay);
    DateTime? target;

    if (widget.minDate != null && selected.isBefore(widget.minDate!)) {
      target = widget.minDate!;
    } else if (widget.maxDate != null && selected.isAfter(widget.maxDate!)) {
      target = widget.maxDate!;
    }

    if (target != null) {
      setState(() {
        selectedYear = target!.year;
        selectedMonth = target.month;
        selectedDay = target.day;
      });
      // Snap the wheels back to the target date
      _dayController.animateToItem(selectedDay - 1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      _monthController.animateToItem(selectedMonth - 1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      _yearController.animateToItem(selectedYear - baseYear, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    if ([4, 6, 9, 11].contains(month)) return 30;
    return 31;
  }

  @override
  Widget build(BuildContext context) {
    int maxDays = _getDaysInMonth(selectedMonth, selectedYear);
    if (selectedDay > maxDays) selectedDay = maxDays;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 168.h,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _dayController,
                      itemExtent: 56.h,
                      squeeze: 1.2,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedDay = index + 1;
                        });
                        _enforceConstraints();
                      },
                      children: List.generate(maxDays, (index) {
                        bool isActive = index == (selectedDay - 1);
                        return Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.roboto400Regular20(
                              color: isActive ? Colors.black : const Color(0xFFA8A8A8),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _monthController,
                      itemExtent: 56.h,
                      squeeze: 1.2,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedMonth = index + 1;
                          int newMax = _getDaysInMonth(selectedMonth, selectedYear);
                          if (selectedDay > newMax) {
                            selectedDay = newMax;
                            _dayController.jumpToItem(selectedDay - 1);
                          }
                        });
                        _enforceConstraints();
                      },
                      children: List.generate(12, (index) {
                        bool isActive = index == (selectedMonth - 1);
                        return Center(
                          child: Text(
                            months[index],
                            style: AppTextStyles.roboto400Regular20(
                              color: isActive ? Colors.black : const Color(0xFFA8A8A8),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _yearController,
                      itemExtent: 56.h,
                      squeeze: 1.2,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedYear = baseYear + index;
                          int newMax = _getDaysInMonth(selectedMonth, selectedYear);
                          if (selectedDay > newMax) {
                            selectedDay = newMax;
                            _dayController.jumpToItem(selectedDay - 1);
                          }
                        });
                        _enforceConstraints();
                      },
                      children: List.generate(maxYearCount, (index) {
                        bool isActive = index == (selectedYear - baseYear);
                        return Center(
                          child: Text(
                            '${baseYear + index}',
                            style: AppTextStyles.roboto400Regular20(
                              color: isActive ? Colors.black : const Color(0xFFA8A8A8),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            PrimaryButton(
              text: 'Done',
              onPressed: () {
                Navigator.of(context).pop(DateTime(selectedYear, selectedMonth, selectedDay));
              },
            ),
          ],
        ),
      ),
    );
  }
}
