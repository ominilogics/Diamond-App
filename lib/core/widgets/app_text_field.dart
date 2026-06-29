import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextStyle? labelStyle;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLength;

  const AppTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.labelStyle,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.maxLength,
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
            if (labelText != null) ...[
              Text(
                labelText!,
                style: labelStyle ?? AppTextStyles.colitez400Italic16(),
              ),
              SizedBox(height: 8.h),
            ],
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: 44.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: hasError ? Colors.red : const Color(0xFF000000),
                  width: 0.5.w,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: AppColors.primaryButtonGradientStart,
                    selectionColor: AppColors.primaryButtonGradientStart.withOpacity(0.3),
                    selectionHandleColor: AppColors.primaryButtonGradientStart,
                  ),
                ),
                child: TextField(
                  controller: controller,
                focusNode: focusNode,
                textInputAction: textInputAction,
                onSubmitted: onFieldSubmitted,
                obscureText: obscureText,
                readOnly: readOnly,
                maxLines: maxLines,
                keyboardType: keyboardType,
                inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null,
                cursorColor: AppColors.primaryButtonGradientStart,
                style: AppTextStyles.roboto400Regular14(color: Colors.black),
                onChanged: (val) {
                  state.didChange(val);
                },
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppTextStyles.roboto300Light14(
                    color: const Color(0xFFA8A8A8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  prefixIcon: prefixIcon,
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 40.w,
                    minHeight: 20.h,
                    maxHeight: 44.h,
                  ),
                  suffixIcon: suffixIcon,
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 40.w,
                    minHeight: 20.h,
                    maxHeight: 44.h,
                  ),
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
