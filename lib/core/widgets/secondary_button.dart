import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SecondaryButton({
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.black,
            width: 0.5.w,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: isDisabled ? null : onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: kIsWeb ? 24 : 24.w,
                      height: kIsWeb ? 24 : 24.w,
                      child: const CircularProgressIndicator(
                        color: Colors.black,
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
