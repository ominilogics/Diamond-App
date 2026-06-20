import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;

    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              AppBar2(title: texts.notificationsTitle),
              SizedBox(height: 24.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's notifications (no header shown in design)
                    NotificationCard(
                      title: texts.newCardsDropped,
                      description: texts.newCardsDesc,
                      time: texts.time3m,
                    ),
                    SizedBox(height: 16.h),
                    NotificationCard(
                      title: texts.limitedTimeOffer,
                      description: texts.limitedTimeDesc,
                      time: texts.time3h,
                    ),
                    SizedBox(height: 16.h),
                    NotificationCard(
                      title: texts.freeCardReady,
                      description: texts.freeCardDesc,
                      time: texts.time5h,
                    ),

                    SizedBox(height: 24.h),

                    // Yesterday
                    Text(
                      texts.yesterday,
                      style: AppTextStyles.roboto500Medium14(),
                    ),
                    SizedBox(height: 16.h),
                    NotificationCard(
                      title: texts.happySiblingsDay,
                      description: texts.happySiblingsDesc,
                      time: texts.time1d,
                    ),

                    SizedBox(height: 24.h),

                    // Apr 7, 2026
                    Text(
                      texts.apr7_2026,
                      style: AppTextStyles.roboto500Medium14(),
                    ),
                    SizedBox(height: 16.h),
                    NotificationCard(
                      title: texts.mothersDayComing,
                      description: texts.mothersDayDesc,
                      time: texts.time3d,
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
