import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

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
        border: Border.all(
          color: const Color(0xFF000000),
          width: 0.5.w,
        ),
      ),
      child: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: [
              // Front Cover
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
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: coverTextController,
                      builder: (context, value, child) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return Positioned(
                          top: 253.h,
                          bottom: 24.h,
                          left: 29.w,
                          right: 29.w,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              value.text.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bizudMincho400Regular12(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Inside Card
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
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: insideMessageController,
                      builder: (context, value, child) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return Positioned(
                          top: 20.h,
                          bottom: 20.h,
                          left: 20.w,
                          right: 20.w,
                          child: Center(
                            child: Text(
                              value.text.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bizudMincho400Regular12(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Envelope / Third Step
              Center(
                child: SvgPicture.asset(
                  AppAssets.gatta,
                  fit: BoxFit.contain,
                  width: 255.w,
                  height: 357.h,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Row(
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
          ),
        ],
      ),
    );
  }
}
