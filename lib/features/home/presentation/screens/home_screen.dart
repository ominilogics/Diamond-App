import 'package:flutter/material.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/categories_section.dart';
import '../widgets/islamic_cards_section.dart';
import '../widgets/featured_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),

          // 1. Top Bar
          AppBar1(
            title: texts.welcomeBack,
            textStyle: AppTextStyles.colitez400Italic32(),
          ),

          // 2. Welcome Section
          Padding(
            padding: EdgeInsets.only(left: 30.w, right: 60),
            child: Text(
              texts.welcomeSubtitle,
              style: AppTextStyles.roboto300Light13(),
            ),
          ),
          SizedBox(height: 24.h),

          // 3. Search Bar
          const SearchBarWidget(),
          SizedBox(height: 32.h),

          // 4. Categories Section
          const CategoriesSection(),
          SizedBox(height: 32.h),

          // 5. Islamic Cards Section
          const IslamicCardsSection(),
          SizedBox(height: 32.h),

          // 6. Featured Cards Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              texts.featuredCards,
              style: AppTextStyles.colitez400Italic24(),
            ),
          ),
          SizedBox(height: 16.h),

          // Featured Cards Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GridView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 171.w / 204.h,
              ),
              children: [
                FeaturedCard(
                  cardId: 'home_card_1',
                  title: texts.eidCard1,
                  cardColor: AppColors.card1,
                ),
                FeaturedCard(
                  cardId: 'home_card_2',
                  title: texts.eidCard1,
                  cardColor: AppColors.card5,
                ),
                FeaturedCard(
                  cardId: 'home_card_3',
                  title: texts.eidCard1,
                  cardColor: AppColors.card3,
                ),
                FeaturedCard(
                  cardId: 'home_card_4',
                  title: texts.eidCard1,
                  cardColor: AppColors.card4,
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h), // Bottom padding
        ],
      ),
    );
  }
}
