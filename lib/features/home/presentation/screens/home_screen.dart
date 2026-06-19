import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/categories_section.dart';
import '../widgets/islamic_cards_section.dart';
import '../widgets/featured_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),

          // 1. Top Bar
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Home', style: AppTextStyles.colitez400Italic20()),
                GestureDetector(
                  onTap: () {
                    // TODO: Handle notification tap
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: SvgPicture.asset(
                      AppAssets.notification,
                      width: 25.w,
                      height: 25.h,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // 2. Welcome Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: AppTextStyles.colitez400Italic32(),
                ),
                // SizedBox(height: 4.h),
                Text(
                  '   Someone\'s smile could start with a card from you today.',
                  style: AppTextStyles.roboto300Light13(),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // 3. Search Bar
          const SearchBarWidget(),
          SizedBox(height: 24.h),

          // 4. Categories Section
          const CategoriesSection(),
          SizedBox(height: 24.h),

          // 5. Islamic Cards Section
          const IslamicCardsSection(),
          SizedBox(height: 24.h),

          // 6. Featured Cards Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Featured Cards',
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
              children: const [
                FeaturedCard(title: 'Eid Card 1', cardColor: AppColors.card1),
                FeaturedCard(title: 'Eid Card 1', cardColor: AppColors.card5),
                FeaturedCard(title: 'Eid Card 1', cardColor: AppColors.card3),
                FeaturedCard(title: 'Eid Card 1', cardColor: AppColors.card4),
              ],
            ),
          ),
          SizedBox(height: 40.h), // Bottom padding
        ],
      ),
    );
  }
}
