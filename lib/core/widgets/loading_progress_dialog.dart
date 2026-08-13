import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LoadingProgressDialog extends StatelessWidget {
  final ValueNotifier<String> statusNotifier;

  LoadingProgressDialog({
    super.key,
    required String text,
  }) : statusNotifier = ValueNotifier<String>(text);

  const LoadingProgressDialog.dynamic({
    super.key,
    required this.statusNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Center(
          child: Container(
            width: 190.w,
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 18.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
                width: 0.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryButtonGradientStart,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 20.h,
                  child: ValueListenableBuilder<String>(
                    valueListenable: statusNotifier,
                    builder: (context, statusText, child) {
                      return Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            statusText,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.roboto500Medium14(
                              fontSize: 14.sp,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}