import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/app_assets.dart';

import '../routing/app_routes.dart';

class AppBar2 extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const AppBar2({super.key, required this.title, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBackPressed ?? () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoute.main.name);
                }
              },
              customBorder: const CircleBorder(),
              splashColor: AppColors.primaryButtonGradientStart.withOpacity(0.2),
              highlightColor: AppColors.primaryButtonGradientStart.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              child: SvgPicture.asset(
                AppAssets.backArrow,
                width: 20.w,
                height: 15.h,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          ),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.colitez400Italic20(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 48.w,
          ), // To balance the back arrow (20w + 28w padding)
        ],
      ),
    );
  }
}
