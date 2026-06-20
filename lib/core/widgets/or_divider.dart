import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Container(height: 0.5, color: const Color(0xFFA8A8A8)),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text('OR', style: AppTextStyles.roboto400Regular14()),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Container(height: 0.5, color: const Color(0xFFA8A8A8)),
          ),
        ),
      ],
    );
  }
}
