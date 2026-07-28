import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../../core/widgets/carousel_dots_indicator.dart';
import '../../../cards/domain/entities/card_entity.dart';
import '../../../cards/presentation/providers/cards_provider.dart';

class HomeBannerCarousel extends HookConsumerWidget {
  const HomeBannerCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState<int>(0);
    final featuredCardsAsync = ref.watch(featuredCardsStreamProvider);

    final cards = featuredCardsAsync.valueOrNull ?? [];
    final isLoading = featuredCardsAsync.isLoading || cards.isEmpty;
    const totalItems = 3;




    // Auto-scroll periodic timer (happens ONLY when shimmer is gone)
    useEffect(() {
      if (isLoading || totalItems <= 1) return null;

      final timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (pageController.hasClients) {
          final current = pageController.page?.round() ?? currentPage.value;
          final nextPage = (current + 1) % totalItems;
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      });
      return timer.cancel;
    }, [pageController, isLoading, totalItems]);

    // Full card shimmer loading state - show shimmer on whole card container, hide all text until loaded
    if (isLoading) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 141.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          const CarouselDotsIndicator(
            count: 3,
            currentIndex: 0,
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 141.h,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) => currentPage.value = index,
            itemCount: totalItems,
            itemBuilder: (context, pageIndex) {
              final card = cards[pageIndex % cards.length];
              return _BannerItem(card: card);
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Reusable carousel dots indicator
        CarouselDotsIndicator(
          count: totalItems,
          currentIndex: currentPage.value,
        ),
      ],
    );

  }
}

class _BannerItem extends StatelessWidget {
  final CardEntity card;

  const _BannerItem({required this.card});

  @override
  Widget build(BuildContext context) {
    if (card.coverImageUrl.isEmpty) {
      return _buildFullBanner(context, null);
    }

    return CachedNetworkImage(
      imageUrl: card.coverImageUrl,
      placeholder: (context, url) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: 141.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, err) => _buildFullBanner(context, null),
      imageBuilder: (context, imageProvider) => _buildFullBanner(context, imageProvider),
    );
  }

  Widget _buildFullBanner(BuildContext context, ImageProvider? imageProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        height: 141.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFF7272),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // Left text content (Vertically Centered)
              Positioned(
                left: 20.w,
                top: 0,
                bottom: 0,
                right: 145.w,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Send Thanks\n& Greetings.',
                        style: AppTextStyles.colitez400Italic24(
                          color: Colors.black,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Send a card. Be someone\'s\nreason to smile.',
                        style: AppTextStyles.roboto300Light13(
                          color: Colors.black,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              // Right aligned card: width 114px, height 161px, top spacing 11.h (chopped off at container bottom)
              Positioned(
                right: 20.w,
                top: 11.h,
                width: 114.w,
                height: 161.h,
                child: GestureDetector(
                  onTap: () {
                    AppHelpers.dismissKeyboard();
                    context.pushNamed(
                      AppRoute.cardDetail.name,
                      extra: {
                        'cardId': card.id,
                        'title': card.title,
                        'cardColorValue': card.colorValue ?? 0xFFFF5E60,
                        'coverImageUrl': card.coverImageUrl,
                        'frontMessage': card.defaultFrontMessage,
                        'initialMessage': card.defaultInsideMessage,
                      },
                    );
                  },
                  child: Transform.rotate(
                    angle: 0.05,
                    child: Container(
                      width: 114.w,
                      height: 161.h,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.zero,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x73000000),
                            offset: Offset(4, 6),
                            blurRadius: 9,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          imageProvider != null
                              ? Image(
                                  image: imageProvider,
                                  width: 114.w,
                                  height: 161.h,
                                  fit: BoxFit.cover,
                                )
                              : SvgPicture.asset(
                                  AppAssets.gatta,
                                  fit: BoxFit.cover,
                                ),
                          if (card.defaultFrontMessage != null &&
                              card.defaultFrontMessage!.isNotEmpty)
                            Positioned(
                              top: 112.h,
                              left: 10.w,
                              right: 10.w,
                              child: Text(
                                card.defaultFrontMessage!.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bizudMincho(
                                  fontSize: 8.sp,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                        ],
                      ),

                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
