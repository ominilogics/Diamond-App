import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';

class MyEventCard extends StatelessWidget {
  final String date;
  final String title;
  final String reminder;

  const MyEventCard({
    super.key,
    required this.date,
    required this.title,
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: AppTextStyles.roboto400Regular12(
                    color: const Color(0xFF525252),
                    letterSpacing: -0.36,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: AppTextStyles.colitez400Italic24(
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  reminder,
                  style: AppTextStyles.roboto400Regular12(
                    color: const Color(0xFF525252),
                    letterSpacing: -0.36,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: Colors.black, size: 24.w),
        ],
      ),
    );
  }
}
