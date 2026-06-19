import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                iconPath: AppAssets.home,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                iconPath: AppAssets.cards,
                label: 'Cards',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                iconPath: AppAssets.favourite,
                label: 'Favorite',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                iconPath: AppAssets.settings,
                label: 'Settings',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent, // Ensures the entire expanded space is tappable
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: AnimatedScale(
            scale: isSelected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 24.w,
                  height: 24.h,
                  colorFilter: isSelected 
                      ? const ColorFilter.mode(Colors.black, BlendMode.srcIn)
                      : const ColorFilter.mode(Colors.black54, BlendMode.srcIn),
                ),
                SizedBox(height: 4.h),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: isSelected
                      ? AppTextStyles.roboto400Regular12(color: Colors.black).copyWith(fontWeight: FontWeight.w600)
                      : AppTextStyles.roboto400Regular12(color: Colors.black54),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
