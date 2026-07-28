import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../../core/widgets/carousel_dots_indicator.dart';

class EditCardCarousel extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final String? coverImageUrl;
  final TextEditingController coverTextController;
  final TextEditingController insideMessageController;

  const EditCardCarousel({
    super.key,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.coverTextController,
    required this.insideMessageController,
    this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 453.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
      ),
      child: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: [
              // Front Cover
              Center(
                child: SizedBox(
                  width: 255.w,
                  height: 357.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: coverImageUrl!,
                          fit: BoxFit.cover,
                          width: 255.w,
                          height: 357.h,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 255.w,
                              height: 357.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => SizedBox(
                            width: 255.w,
                            height: 357.h,
                            child: const Icon(Icons.error),
                          ),
                        )
                      else
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 255.w,
                            height: 357.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 253.h,
                        bottom: 24.h,
                        left: 29.w,
                        right: 29.w,
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: coverTextController,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) return const SizedBox.shrink();
                            return Align(
                              alignment: Alignment.topCenter,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  width: 197.w,
                                  child: Text(
                                    value.text.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bizudMincho400Regular12(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Inside Card
              Center(
                child: SizedBox(
                  width: 255.w,
                  height: 358.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AppAssets.backSide,
                        fit: BoxFit.cover,
                        width: 255.w,
                        height: 358.h,
                      ),
                      Positioned(
                        top: 20.h,
                        bottom: 20.h,
                        left: 20.w,
                        right: 20.w,
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: insideMessageController,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) return const SizedBox.shrink();
                            return Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 215.w,
                                  child: Text(
                                    value.text.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bizudMincho400Regular12(
                                      color: const Color(0xFF2C2C2C),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },


                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Envelope / Third Step (3-Layer Real Envelope - Vertically & Horizontally Centered with Bottom Padding)
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 390.w,
                    height: 453.h,
                    child: Stack(
                      children: [
                        // Preview Button
                        Positioned(
                          top: 15.h,
                          left: 141.w,
                          width: 108.w,
                          height: 26.h,
                          child: GestureDetector(
                            onTap: () {
                              AppHelpers.dismissKeyboard();
                              context.pushNamed(
                                AppRoute.previewCard.name,
                                extra: {
                                  'coverImageUrl': coverImageUrl,
                                  'frontMessage': coverTextController.text,
                                  'message': insideMessageController.text,
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAEAEA),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.eye,
                                    width: 16.w,
                                    height: 16.h,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Preview',
                                    style: AppTextStyles.colitez400Italic32(
                                      fontSize: 12.sp,
                                      color: Colors.black,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Layer 1: Envelope Back Side
                        Positioned(
                          top: 120.h,
                          left: 61.89.w,
                          width: 272.55.w,
                          height: 253.63.h,
                          child: SvgPicture.asset(
                            AppAssets.envelopeBack,
                            fit: BoxFit.fill,
                          ),
                        ),

                        // Layer 2: The Card inside Envelope (tucked inside pocket, height 182.h so bottom never overflows)
                        Positioned(
                          top: 151.32.h,
                          left: 92.w,
                          width: 211.w,
                          height: 182.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.zero,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (coverImageUrl != null &&
                                    coverImageUrl!.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: coverImageUrl!,
                                    fit: BoxFit.cover,
                                    width: 211.w,
                                    height: 182.h,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.white),
                                        ),
                                    imageBuilder: (context, imageProvider) => Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                          width: 211.w,
                                          height: 182.h,
                                        ),
                                        Positioned(
                                          bottom: 16.h,
                                          left: 12.w,
                                          right: 12.w,
                                          child: ValueListenableBuilder<TextEditingValue>(
                                            valueListenable: coverTextController,
                                            builder: (context, value, child) {
                                              if (value.text.isEmpty) {
                                                return const SizedBox.shrink();
                                              }
                                              return Text(
                                                value.text.toUpperCase(),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.bizudMincho400Regular12(
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: const Color(0xFFC04B5D),
                                        ),
                                  )
                                else
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        AppAssets.backSide,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        width: 211.w,
                                        height: 182.h,
                                      ),
                                      Positioned(
                                        bottom: 16.h,
                                        left: 12.w,
                                        right: 12.w,
                                        child: ValueListenableBuilder<TextEditingValue>(
                                          valueListenable: coverTextController,
                                          builder: (context, value, child) {
                                            if (value.text.isEmpty) {
                                              return const SizedBox.shrink();
                                            }
                                            return Text(
                                              value.text.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.bizudMincho400Regular12(
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Layer 3: Envelope Front Side (PNG)
                        Positioned(
                          top: 216.29.h,
                          left: 52.w,
                          width: 292.17.w,
                          height: 157.37.h,
                          child: Image.asset(
                            AppAssets.envelopeFront,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: CarouselDotsIndicator(count: 3, currentIndex: currentPage),
          ),
        ],
      ),
    );
  }
}
