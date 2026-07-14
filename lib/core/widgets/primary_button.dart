import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    return Opacity(
      opacity: onPressed == null && !isLoading ? 0.5 : 1.0,
      child: Container(
        width: double.infinity,
        height: kIsWeb ? 44 : 44.h,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Material(
          color: Colors.transparent, // Ensures the gradient shows through
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: isDisabled ? null : onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: kIsWeb ? 24 : 24.w,
                      height: kIsWeb ? 24 : 24.w,
                      child: const CircularProgressIndicator(
                        color: Colors.black, // Matching the default text color
                        strokeWidth: 2.0,
                      ),
                    )
                  : Text(
                      text,
                      style: AppTextStyles.colitez400Italic21(),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
