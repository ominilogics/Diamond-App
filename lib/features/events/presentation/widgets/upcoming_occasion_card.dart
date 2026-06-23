import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class UpcomingOccasionCard extends StatelessWidget {
  final String date;
  final String title;

  const UpcomingOccasionCard({
    super.key,
    required this.date,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryButtonGradient,
            ),
            child: Center(
              child: Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: 24.w,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  date,
                  style: AppTextStyles.roboto400Regular12(
                    fontSize: 10.sp,
                    color: const Color(0xFF525252),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  title,
                  style: AppTextStyles.colitez400Italic20(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
