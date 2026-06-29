import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, isSuccess: true, icon: Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, isSuccess: false, icon: Icons.error_outline);
  }

  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_outline,
  }) {
    // For backward compatibility with existing calls, determine if it's an error based on icon or default to false
    final isSuccess = icon == Icons.check_circle_outline || icon == Icons.check;
    _show(context, message, isSuccess: isSuccess, icon: icon);
  }

  static void _show(
    BuildContext context,
    String message, {
    required bool isSuccess,
    required IconData icon,
  }) {
    final fToast = FToast();
    fToast.init(context);

    // Remove current toast if any
    fToast.removeCustomToast();

    final textColor = Colors.black;
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primaryButtonGradientStart,
        AppColors.primaryButtonGradientEnd,
      ],
    );

    Widget iconWidget;
    if (isSuccess) {
      iconWidget = Icon(icon, color: Colors.green, size: 24.sp);
    } else {
      iconWidget = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient.createShader(bounds),
        child: Icon(icon, size: 24.sp),
      );
    }

    Widget toastContent = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSuccess ? Colors.green : AppColors.primaryButtonGradientStart,
          width: 0.5.w,
        ),
      ),
      child: Row(
        children: [
          iconWidget,
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.roboto500Medium14().copyWith(
                color: textColor,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );

    Widget toast = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: toastContent,
    );

    fToast.showToast(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: toast,
        ),
      ),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 3),
      positionedToastBuilder: (BuildContext context, Widget child, ToastGravity? gravity) {
        Widget positionedWidget = Positioned(
          top: MediaQuery.of(context).padding.top + 16.h,
          left: 0,
          right: 0,
          child: child,
        );
        return positionedWidget;
      },
    );
  }
}
