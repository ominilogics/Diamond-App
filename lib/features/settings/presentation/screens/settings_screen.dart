import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../../../../core/widgets/primary_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    const bool isLoggedIn = true;

    return Column(
      children: [
        SizedBox(height: 12.h),
        AppBar1(title: texts.navSettings),
        SizedBox(height: 24.h),
        Expanded(
          child: isLoggedIn
              ? _buildLoggedInContent(context, texts)
              : _buildLoggedOutContent(context, texts),
        ),
      ],
    );
  }

  Widget _buildLoggedOutContent(BuildContext context, AppLocalizations texts) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            texts.loginPrompt,
            style: AppTextStyles.roboto400Regular20(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          PrimaryButton(
            text: texts.loginAction,
            onPressed: () {
              context.pushNamed(AppRoute.login.name);
            },
          ),
          SizedBox(
            height: 80.h,
          ), // Shift up slightly to visually balance above bottom nav
        ],
      ),
    );
  }

  Widget _buildLoggedInContent(BuildContext context, AppLocalizations texts) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Profile Container
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GestureDetector(
              onTap: () => context.pushNamed(AppRoute.editProfile.name),
              child: Container(
                width: double.infinity,
                height: 93.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFF000000),
                    width: 0.5.w,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    // Avatar
                    Container(
                      width: 57.w,
                      height: 57.w,
                      decoration: BoxDecoration(
                        color: AppColors.card2, // The purple color
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF000000),
                          width: 0.5.w,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          texts.profileInitial,
                          style: AppTextStyles.roboto400Regular20(
                            color: const Color(0xFF000000),
                            fontSize: 24.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            texts.profileName,
                            style: AppTextStyles.roboto400Regular18(),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            texts.profileEmail,
                            style: AppTextStyles.roboto300Light12(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SvgPicture.asset(
                      AppAssets.forwardArrow,
                      width: 8.w,
                      height: 14.h,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 20.w),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Preferences Container
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFF000000),
                  width: 0.5.w,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texts.preferences,
                    style: AppTextStyles.colitez400Italic24(),
                  ),
                  SizedBox(height: 24.h),
                  _buildPreferenceItem(texts.myCart),
                  _buildDivider(),
                  _buildPreferenceItem(texts.subscriptions),
                  _buildDivider(),
                  _buildPreferenceItem(
                    texts.privacyPolicy,
                    onTap: () => context.pushNamed(AppRoute.privacyPolicy.name),
                  ),
                  _buildDivider(),
                  _buildPreferenceItem(
                    texts.termsAndConditions,
                    onTap: () => context.pushNamed(AppRoute.termsAndConditions.name),
                  ),
                  _buildDivider(),
                  _buildPreferenceItem(texts.logout, isLast: true),
                ],
              ),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(String title, {bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.roboto400Regular16()),
            SvgPicture.asset(
              AppAssets.forwardArrow,
              width: 8.w,
              height: 14.h,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 0.5.h,
        color: const Color(0xFFA8A8A8),
      ),
    );
  }
}
