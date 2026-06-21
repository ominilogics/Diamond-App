import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/animated_like_button.dart';

class FeaturedCard extends StatefulWidget {
  final String title;
  final Color cardColor;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const FeaturedCard({
    super.key,
    required this.title,
    required this.cardColor,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<FeaturedCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(FeaturedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  void _handleFavoriteToggle() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                    colorFilter: ColorFilter.mode(widget.cardColor, BlendMode.srcIn),
                  ),
                  SizedBox(height: 18.h),
                  Text(widget.title, style: AppTextStyles.roboto400Regular14()),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            // Favorite icon
            Positioned(
              top: 14.h,
              right: 14.w,
              child: AnimatedLikeButton(
                isLiked: _isFavorite,
                onTap: _handleFavoriteToggle,
                size: 23.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
