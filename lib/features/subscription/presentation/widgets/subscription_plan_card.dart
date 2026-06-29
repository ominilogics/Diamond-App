import 'package:daimond/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_text_styles.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final String title;
  final String description;
  final String cardsCount;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.title,
    required this.description,
    required this.cardsCount,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(0.5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r + 0.5.w),
          gradient: isSelected
              ? AppColors.primaryButtonGradient
              : const LinearGradient(
                  colors: [Color(0xFFE5E5E5), Color(0xFFE5E5E5)],
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
          decoration: BoxDecoration(
            color: isSelected ? null : Colors.white,
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Color.lerp(Colors.white, AppColors.primaryButtonGradientStart, 0.08)!,
                      Color.lerp(Colors.white, AppColors.primaryButtonGradientEnd, 0.08)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTextStyles.roboto500Medium14().copyWith(
                      color: Colors.black, // Title color is now consistently bold and dark
                      letterSpacing: 2.0,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    price,
                    style: AppTextStyles.colitez400Italic20().copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.only(right: 32.w), // Added horizontal padding to subtext
                child: Text(
                  description,
                  style: AppTextStyles.roboto400Regular12().copyWith(
                    color: const Color(0xFF757575),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    cardsCount.split(' ').first,
                    style: AppTextStyles.colitez400Italic32().copyWith(
                      color: Colors.black,
                      fontSize: 48.sp,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      "Cards",
                      style: AppTextStyles.roboto500Medium14().copyWith(
                        color: const Color(0xFF424242),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
