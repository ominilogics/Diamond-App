import 'package:flutter/material.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../home/presentation/widgets/featured_card.dart';

class CardsScreen extends HookConsumerWidget {
  final String? title;
  final bool showBackButton;

  const CardsScreen({super.key, this.title, this.showBackButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final screenTitle = title ?? texts.navCards;

    final selectedIndex = useState(0);

    final List<String> categories = [
      texts.all,
      texts.love,
      texts.birthday,
      texts.thankYou,
      texts.anniversary,
    ];

    // Using dummy data array for 10 cards
    final List<Color> cardColors = [
      AppColors.card1,
      AppColors.card3,
      AppColors.card4,
      AppColors.card5,
      AppColors.card1,
      AppColors.card3,
      AppColors.card4,
      AppColors.card5,
      AppColors.card1,
      AppColors.card3,
    ];

    Widget content = SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 12.h),
          showBackButton
              ? AppBar2(title: screenTitle)
              : AppBar1(title: screenTitle),
          SizedBox(height: 24.h),

          SizedBox(
            height: 30.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final isSelected = selectedIndex.value == index;
                return GestureDetector(
                  onTap: () {
                    selectedIndex.value = index;
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 76.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    height: 30.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? null
                          : Colors.transparent,
                      gradient: isSelected
                          ? AppColors.primaryButtonGradient
                          : null,
                      borderRadius: BorderRadius.circular(20.r),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: const Color(0xFF000000),
                              width: 0.5.w,
                            ),
                    ),
                    child: Text(
                      categories[index],
                      style: AppTextStyles.roboto400Regular14(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 24.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 171.w / 204.h,
              ),
              itemBuilder: (context, index) {
                return FeaturedCard(
                  title: texts.eidCard1,
                  cardColor: cardColors[index],
                );
              },
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );

    if (showBackButton) {
      return GradientScaffold(body: SafeArea(child: content));
    }

    return content;
  }
}
