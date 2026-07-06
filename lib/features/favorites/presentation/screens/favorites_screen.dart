import 'package:flutter/material.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../../../home/presentation/widgets/featured_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import 'package:collection/collection.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;

    final favoritesState = ref.watch(favoritesProvider);
    final favorites = favoritesState.valueOrNull ?? [];
    
    final allCardsState = ref.watch(allCardsStreamProvider);
    final allCards = allCardsState.valueOrNull ?? [];

    if (favorites.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 12.h),
          AppBar1(title: texts.favoritesTitle),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AppAssets.favouritesEmpty),
                SizedBox(height: 24.h),
                Text(
                  texts.noCardsHere,
                  style: AppTextStyles.colitez400Italic32(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 80.h,
                ), // Offset from center to account for bottom nav
              ],
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 12.h),
          AppBar1(title: texts.favoritesTitle),
          SizedBox(height: 24.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favorites.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 171.w / 204.h,
              ),
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final card = allCards.firstWhereOrNull((c) => c.id == favorite.cardId);
                
                return FeaturedCard(
                  cardId: favorite.cardId,
                  title: favorite.title,
                  cardColor: Color(favorite.colorValue),
                  coverImageUrl: card?.coverImageUrl,
                  frontMessage: card?.defaultFrontMessage,
                  insideMessage: card?.defaultInsideMessage,
                );
              },
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
