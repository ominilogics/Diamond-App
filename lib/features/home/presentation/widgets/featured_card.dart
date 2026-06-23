import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/animated_like_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/favorites/domain/entities/favorite_entity.dart';
import '../../../../features/favorites/presentation/providers/favorites_provider.dart';

class FeaturedCard extends ConsumerWidget {
  final String cardId;
  final String title;
  final Color cardColor;
  final VoidCallback? onTap;

  const FeaturedCard({
    super.key,
    required this.cardId,
    required this.title,
    required this.cardColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteAsync = ref.watch(isFavoriteProvider(cardId));
    final isFavorite = isFavoriteAsync.valueOrNull ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 171.w,
        height: 204.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
        ),
        child: Stack(
          children: [
            // Center content
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    AppAssets.gatta,
                    width: 84.5.w,
                    height: 118.3.h,
                    colorFilter: ColorFilter.mode(
                      cardColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(title, style: AppTextStyles.roboto400Regular14()),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            // Favorite icon
            Positioned(
              top: 14.h,
              right: 14.w,
              child: AnimatedLikeButton(
                isLiked: isFavorite,
                onTap: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(
                        FavoriteEntity(
                          cardId: cardId,
                          title: title,
                          colorValue: cardColor.value,
                          supabaseUserId: 'dummy_user_uid',
                          favoritedAt: DateTime.now(),
                        ),
                      );
                },
                size: 23.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
