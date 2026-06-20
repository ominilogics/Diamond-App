import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
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
    final texts = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
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
                activeIconPath: AppAssets.homeFilled,
                label: texts.navHome,
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                iconPath: AppAssets.events,
                activeIconPath: AppAssets.eventsFilled,
                label: texts.navEvents,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                iconPath: AppAssets.favourite,
                activeIconPath: AppAssets.favouriteFilled,
                label: texts.navFavorite,
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                iconPath: AppAssets.settings,
                activeIconPath: AppAssets.settingsFilled,
                label: texts.navSettings,
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
  final String activeIconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.iconPath,
    required this.activeIconPath,
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
          color: Colors
              .transparent, // Ensures the entire expanded space is tappable
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                isSelected ? activeIconPath : iconPath,
                // width: 24.w,
                // height: 24.h,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: isSelected
                    ? AppTextStyles.roboto400Regular12(
                        color: AppColors.primaryButtonGradientStart,
                        fontWeight: FontWeight.w600,
                      )
                    : AppTextStyles.roboto400Regular12(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
