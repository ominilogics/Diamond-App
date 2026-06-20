import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    final titles = [
      texts.love,
      texts.birthday,
      texts.thankYou,
      texts.anniversary,
    ];

    final colors = [
      AppColors.card1,
      AppColors.card2,
      AppColors.card3,
      AppColors.card4,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(texts.categories, style: AppTextStyles.colitez400Italic24()),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    AppRoute.cards.name,
                    extra: texts.categories,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 8.h),
                  child: Text(
                    texts.viewAll,
                    style: AppTextStyles.roboto400Regular13(
                      color: const Color(0xFF525252),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 102
              .h, // Precisely sized for 72 circle + 10 gap + text to remove extra vertical space
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: titles.length,
            separatorBuilder: (context, index) => SizedBox(width: 20.w),
            itemBuilder: (context, index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF000000),
                        width: 0.5.w,
                      ),
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 72.w,
                        height: 72.w,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: SvgPicture.asset(
                              AppAssets.gatta,
                              width: 44.w,
                              height: 67.h,
                              fit: BoxFit.fill,
                              colorFilter: ColorFilter.mode(
                                colors[index],
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    titles[index],
                    style: AppTextStyles.roboto400Regular14(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
