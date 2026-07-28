import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class CarouselDotsIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final double activeWidth;
  final double inactiveWidth;
  final double height;

  const CarouselDotsIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeWidth = 18.0,
    this.inactiveWidth = 6.0,
    this.height = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(right: index == count - 1 ? 0 : 4.w),
          width: isActive ? activeWidth.w : inactiveWidth.w,
          height: height.h,
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryButtonGradient : null,
            color: isActive ? null : const Color(0xFFFF8B8D),
            borderRadius: BorderRadius.circular((height / 2).r),
          ),
        );
      }),
    );
  }
}
