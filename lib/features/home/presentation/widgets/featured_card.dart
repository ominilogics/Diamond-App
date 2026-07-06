import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/animated_like_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../features/favorites/domain/entities/favorite_entity.dart';
import '../../../../features/favorites/presentation/providers/favorites_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/shimmers/card_shimmer.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedCard extends ConsumerWidget {
  final String cardId;
  final String title;
  final Color cardColor;
  final String? coverImageUrl;
  final String? frontMessage;
  final String? insideMessage;
  final VoidCallback? onTap;

  const FeaturedCard({
    super.key,
    required this.cardId,
    required this.title,
    required this.cardColor,
    this.coverImageUrl,
    this.frontMessage,
    this.insideMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap ??
          () {
            context.pushNamed(
              AppRoute.cardDetail.name,
              extra: {
                'cardId': cardId,
                'title': title,
                'cardColorValue': cardColor.value,
                'coverImageUrl': coverImageUrl,
                'frontMessage': frontMessage,
                'initialMessage': insideMessage,
              },
            );
          },
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
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: coverImageUrl!,
                            width: 84.5.w,
                            height: 118.3.h,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            placeholder: (context, url) {
                              debugPrint('Shimmer started for card: $title');
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 84.5.w,
                                  height: 118.3.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              );
                            },
                            imageBuilder: (context, imageProvider) {
                              debugPrint('Shimmer ended / Image loaded for card: $title');
                              return Image(
                                image: imageProvider,
                                width: 84.5.w,
                                height: 118.3.h,
                                fit: BoxFit.cover,
                              );
                            },
                            errorWidget: (context, url, error) => SizedBox(width: 84.5.w, height: 118.3.h, child: const Icon(Icons.error)),
                          ),
                          if (frontMessage != null && frontMessage!.isNotEmpty)
                            Positioned(
                              top: 83.h, // ~70% of 118.3.h height
                              left: 10.w,
                              right: 10.w,
                              child: Text(
                                frontMessage!.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bizudMincho(
                                  fontSize: 6.sp,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
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
              child: Consumer(
                builder: (context, ref, child) {
                  final isFavoriteAsync = ref.watch(isFavoriteProvider(cardId));
                  final isFavorite = isFavoriteAsync.valueOrNull ?? false;
                  
                  return AnimatedLikeButton(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
