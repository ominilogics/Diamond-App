import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../theme/app_text_styles.dart';
import 'app_text_field.dart';

class AppLabelledTextField extends HookWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const AppLabelledTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final obscureText = useState(isPassword);
    Widget? actualSuffixIcon = suffixIcon;

    if (isPassword) {
      actualSuffixIcon = GestureDetector(
        onTap: () {
          obscureText.value = !obscureText.value;
        },
        child: Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Icon(
            obscureText.value
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.black54,
            size: 20.sp,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.colitez400Italic16()),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: hintText,
          controller: controller,
          obscureText: obscureText.value,
          keyboardType: keyboardType,
          suffixIcon: actualSuffixIcon,
          validator: validator,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }
}
