import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';
import 'app_text_field.dart';

class AppLabelledTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AppLabelledTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<AppLabelledTextField> createState() => _AppLabelledTextFieldState();
}

class _AppLabelledTextFieldState extends State<AppLabelledTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    Widget? actualSuffixIcon = widget.suffixIcon;

    if (widget.isPassword) {
      actualSuffixIcon = GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
        Text(
          widget.label,
          style: AppTextStyles.colitez400Italic16(),
        ),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: widget.hintText,
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          suffixIcon: actualSuffixIcon,
          validator: widget.validator,
        ),
      ],
    );
  }
}
