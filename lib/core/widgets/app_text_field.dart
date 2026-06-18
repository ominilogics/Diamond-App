import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller?.text ?? '',
      validator: validator,
      builder: (FormFieldState<String> state) {
        final hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: hasError ? Colors.red : const Color(0xFF000000),
                  width: 0.5.w,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                style: AppTextStyles.roboto300Light12(color: Colors.black),
                onChanged: (val) {
                  state.didChange(val);
                },
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppTextStyles.roboto300Light12(),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  suffixIcon: suffixIcon,
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 40.w,
                    minHeight: 20.h,
                    maxHeight: 44.h,
                  ),
                ),
              ),
            ),
            if (hasError && state.errorText != null) ...[
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
