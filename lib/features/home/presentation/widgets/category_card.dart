import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

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
      width: 166.w,
      height: 126.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF000000),
          width: 0.5.w,
        ),
      ),
      child: Stack(
        children: [
          // Left side content
          Positioned(
            left: 18.w, // Calculated from 60px (button left) - 42px (card left)
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.colitez400Italic13(),
                ),
                SizedBox(height: 1.h),
                Text(
                  subtitle,
                  style: AppTextStyles.roboto300Light10(),
                ),
                SizedBox(height: 19.h),
                GestureDetector(
                  onTap: onViewAllPressed,
                  child: Container(
                    width: 53.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'View All',
                      style: AppTextStyles.roboto400Regular9(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right side SVG card (gatta)
          Positioned(
            top: 25.h, // Calculated from 469px (gatta top) - 444px (card top)
            left: 88.w, // Calculated from 130px (gatta left) - 42px (card left)
            child: SvgPicture.asset(
              AppAssets.gatta,
              width: 55.w,
              height: 76.h,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFFFFFF), // White graphic as shown in design
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
