import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import 'category_card.dart';

class IslamicCardsSection extends StatelessWidget {
  const IslamicCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                texts.islamicCards,
                style: AppTextStyles.colitez400Italic24(),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    AppRoute.cards.name,
                    extra: texts.islamicCards,
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
          height: 171.h, // Height of the CategoryCard
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Rendering 3 dummy cards
            separatorBuilder: (context, index) => SizedBox(width: 11.w),
            itemBuilder: (context, index) {
              final titles = [
                texts.eidCards,
                texts.jummaMubarak,
                texts.ramadanKareem,
              ];
              final colors = [
                AppColors.card1,
                AppColors.card2,
                AppColors.card3,
              ];

              return CategoryCard(
                title: titles[index],
                subtitle: texts.cards8,
                backgroundColor: colors[index],
                onViewAllPressed: () {
                  context.pushNamed(AppRoute.cards.name, extra: titles[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
