import 'package:daimond/core/utils/app_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:daimond/l10n/app_localizations.dart';


import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

import '../../../../core/widgets/shimmers/category_shimmer.dart';
import '../../../../core/utils/category_localization.dart';
import '../../../cards/presentation/providers/cards_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../cards/domain/entities/category_entity.dart';

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesStreamProvider);

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
                  AppHelpers.dismissKeyboard();
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
        categoriesAsync.when(
          loading: () => Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: List.generate(
                4,
                (index) =>
                    const Expanded(child: Center(child: CategoryShimmer())),
              ),
            ),
          ),
          error: (error, stack) =>
              const Center(child: Text('Error loading categories')),
          data: (categories) {
            if (categories.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: List.generate(
                    4,
                    (index) =>
                        const Expanded(child: Center(child: CategoryShimmer())),
                  ),
                ),
              );
            }
            final displayCategories = categories.take(4).toList();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: displayCategories
                    .map((cat) => Expanded(child: _CategoryItem(cat: cat)))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryItem extends ConsumerWidget {
  final CategoryEntity cat;
  const _CategoryItem({required this.cat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final firstCardAsync = ref.watch(categoryCardsStreamProvider(cat.id));
    final firstCard = firstCardAsync.valueOrNull?.firstOrNull;
    final hasImage = firstCard != null && firstCard.coverImageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        AppHelpers.dismissKeyboard();
        context.pushNamed(
          AppRoute.cards.name,
          extra: {'title': texts.categories, 'categoryId': cat.id},
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
            ),
            child: ClipOval(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: firstCardAsync.isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 44.w,
                            height: 67.h,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                        )
                      : hasImage
                          ? ClipRRect(
                          borderRadius: BorderRadius.zero,

                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CachedNetworkImage(
                                imageUrl: firstCard.coverImageUrl,
                                width: 44.w,
                                height: 67.h,
                                fit: BoxFit.cover,
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 44.w,
                                    height: 67.h,
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) => SvgPicture.asset(
                                  AppAssets.gatta,
                                  width: 44.w,
                                  height: 67.h,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              if (firstCard.defaultFrontMessage != null &&
                                  firstCard.defaultFrontMessage!.isNotEmpty)
                                Positioned(
                                  top: 47.h, // ~70% of 67.h height
                                  left: 5.w,
                                  right: 5.w,
                                  child: Text(
                                    firstCard.defaultFrontMessage!
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bizudMincho(
                                      fontSize: 4.sp,
                                      color: Colors.white,
                                      height: 1.1,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : SvgPicture.asset(
                          AppAssets.gatta,
                          width: 44.w,
                          height: 67.h,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            cat.name.localized(texts),
            style: AppTextStyles.roboto400Regular13(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),


        ],
      ),
    );
  }
}
