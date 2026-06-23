import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GradientScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            AppBar2(title: l10n.editProfile),
            SizedBox(height: 32.h),

            // Avatar with Badge
            Center(
              child: SizedBox(
                width: 90.w,
                height: 90.w,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Avatar Circle
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        color: AppColors.card2,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF000000),
                          width: 0.5.w,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          l10n.profileInitial,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            fontSize: 40.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    // Edit Badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryButtonGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 14.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Form Fields
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fullNameLabel,
                    style: AppTextStyles.colitez400Italic16(),
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: TextEditingController(text: l10n.profileName),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    l10n.emailLabel,
                    style: AppTextStyles.colitez400Italic16(),
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(hintText: l10n.profileEmail, readOnly: true),
                  SizedBox(height: 40.h),
                  PrimaryButton(text: l10n.saveChanges, onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
