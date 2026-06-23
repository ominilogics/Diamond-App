import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/app_bar2.dart';

class PreviewCardScreen extends StatelessWidget {
  final String message;

  const PreviewCardScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            const AppBar2(title: 'Preview Card'),
            SizedBox(height: 24.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  bottom: 40.h,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Scaled Gatta SVG
                    SvgPicture.asset(
                      AppAssets.gatta,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    
                    // Centered Text over SVG
                    Positioned.fill(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.colitez400Italic32(
                              color: Colors.black, 
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
