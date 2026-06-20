import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_text_styles.dart';
import '../utils/app_assets.dart';

class AppBar2 extends StatelessWidget {
  final String title;

  const AppBar2({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(8.w),
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
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.colitez400Italic20(),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 36.w,
          ), // To balance the back arrow (20w + 16w padding)
        ],
      ),
    );
  }
}
