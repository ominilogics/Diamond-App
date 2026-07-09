import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

class CardDetailCarousel extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final String? coverImageUrl;
  final String? frontMessage;
  final TextEditingController textController;

  const CardDetailCarousel({
    super.key,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.textController,
    this.coverImageUrl,
    this.frontMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 453.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFF000000),
              width: 0.5.w,
            ),
          ),
          child: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: [
              // Front Side
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: coverImageUrl!,
                        fit: BoxFit.cover,
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
                    if (frontMessage != null && frontMessage!.isNotEmpty)
                      Positioned(
                        top: 253.h,
                        bottom: 24.h,
                        left: 29.w,
                        right: 29.w,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            frontMessage!.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bizudMincho400Regular12(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Back Side (Editable Message)
              Center(
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
                      child: Center(
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: textController,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) {
                              return Text(
                                'TYPE YOUR MESSAGE...',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bizudMincho400Regular12(
                                  color: Colors.black54,
                                ),
                              );
                            }
                            return Text(
                              value.text.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bizudMincho400Regular12(
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Envelope / Third Step
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.gatta,
                      fit: BoxFit.contain,
                      width: 255.w,
                      height: 357.h,
                    ),
                    Text(
                      'Envelope Design',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.colitez400Italic32(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Carousel Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = currentPage == index;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 24.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}