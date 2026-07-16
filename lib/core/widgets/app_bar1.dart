import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/app_assets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';

class AppBar1 extends ConsumerWidget {
  final String title;
  final TextStyle? textStyle;

  const AppBar1({super.key, required this.title, this.textStyle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textStyle ?? AppTextStyles.colitez400Italic20()),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.pushNamed(AppRoute.notifications.name);
              },
              customBorder: const CircleBorder(),
              splashColor: AppColors.primaryButtonGradientStart.withOpacity(0.2),
              highlightColor: AppColors.primaryButtonGradientStart.withOpacity(0.1),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: SvgPicture.asset(
                      AppAssets.notification,
                      width: 25.w,
                      height: 25.h,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  if (ref.watch(unreadNotificationsCountProvider) > 0)
                    Positioned(
                      right: 4.w,
                      top: 4.w,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final count = ref.watch(unreadNotificationsCountProvider);
                          final displayCount = count > 9 ? '9+' : count.toString();
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Container(
                              key: ValueKey<int>(count),
                              padding: EdgeInsets.all(3.w),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.w,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                displayCount,
                                style: AppTextStyles.roboto400Regular9(color: Colors.white),
                                textAlign: TextAlign.center,
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
        ],
      ),
    );
  }
}
