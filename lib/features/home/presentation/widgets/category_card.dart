import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback? onViewAllPressed;

  const CategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 242.w,
      height: 171.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
      ),
      child: Stack(
        children: [
          // Text content
          Positioned(
            left: 18.w,
            top: 25.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.colitez400Italic22(height: 1.0),
                ),
                SizedBox(height: 14.h),
                Text(
                  subtitle,
                  style: AppTextStyles.roboto300Light14(height: 1.0),
                ),
              ],
            ),
          ),
          // View All Button
          Positioned(
            top: 126.h,
            left: 18.w,
            child: GestureDetector(
              onTap: onViewAllPressed,
              child: Container(
                width: 71.w,
                height: 22.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  'View All',
                  style: AppTextStyles.roboto400Regular12(),
                ),
              ),
            ),
          ),
          // Inner Gatta (Rotated White Rectangle)
          Positioned(
            top: 18.h,
            left: 138.6.w,
            child: Transform.rotate(
              angle: 7.93 * 3.1415926535897932 / 180,
              child: Container(
                width: 86.6.w,
                height: 119.4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x40000000), // #00000040
                      offset: Offset(-3.w, 7.h),
                      blurRadius: 9.2.r,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
