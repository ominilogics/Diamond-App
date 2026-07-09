import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';

class CustomCardTextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const CustomCardTextField({
    super.key,
    required this.controller,
    required this.maxLines,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryButtonGradientStart,
          selectionColor: AppColors.primaryButtonGradientStart.withOpacity(0.3),
          selectionHandleColor: AppColors.primaryButtonGradientStart,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        cursorColor: AppColors.primaryButtonGradientStart,
        style: AppTextStyles.roboto300Light13(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide(color: Colors.black, width: 0.5.w),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide(color: Colors.black, width: 0.5.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide(color: Colors.black, width: 0.5.w),
          ),
        ),
      ),
    );
  }
}
