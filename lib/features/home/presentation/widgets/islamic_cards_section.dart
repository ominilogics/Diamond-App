import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import 'category_card.dart';

class IslamicCardsSection extends StatelessWidget {
  const IslamicCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      height: 214.h,
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
          SizedBox(height: 27.h), // Mathematically calculated top padding
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 21.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Islamic Cards',
                  style: AppTextStyles.colitez400Italic24(),
                ),
                Text(
                  'View All',
                  style: AppTextStyles.roboto400Regular14(),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          SizedBox(
            height: 126.h, // Height of the CategoryCard
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Rendering 3 dummy cards
              separatorBuilder: (context, index) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final titles = ['Eid\nCards', 'Jumma\nMubarak', 'Ramadan\nKareem'];
                final colors = [
                  AppColors.card1,
                  AppColors.card2,
                  AppColors.card3,
                ];

                return CategoryCard(
                  title: titles[index],
                  subtitle: '8 Cards',
                  backgroundColor: colors[index],
                  onViewAllPressed: () {
                    // TODO: Navigate to specific card listing
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
