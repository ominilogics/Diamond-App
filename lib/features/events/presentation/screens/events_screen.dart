import 'package:daimond/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/events_provider.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/primary_button.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../widgets/add_event_bottom_sheet.dart';
import '../widgets/my_event_card.dart';
import '../widgets/upcoming_occasion_card.dart';

class EventsScreen extends HookConsumerWidget {
  final bool showBackButton;

  const EventsScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;

    final eventsState = ref.watch(eventsProvider);
    final events = eventsState.valueOrNull ?? [];
    final customEvents = events.where((e) => e.isCustom).toList();
    final systemEvents = events.where((e) => !e.isCustom).toList();
    final hasCustomEvents = customEvents.isNotEmpty;
    final hasSystemEvents = systemEvents.isNotEmpty;
    final hasAnyEvents = hasCustomEvents || hasSystemEvents;

    final authState = ref.watch(authStateProvider);
    final user = authState.value?.session?.user ?? Supabase.instance.client.auth.currentUser;
    final bool isLoggedIn = user != null && !user.isAnonymous;

    Widget fab = isLoggedIn ? Container(
      width: 56.w,
      height: 56.w,
      margin: EdgeInsets.only(bottom: showBackButton ? 8.h : 16.h),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryButtonGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            AddEventBottomSheet.show(context);
          },
          child: Center(
            child: Icon(Icons.add, color: Colors.white, size: 28.w),
          ),
        ),
      ),
    ) : const SizedBox.shrink();

    Widget content = RefreshIndicator(
      color: AppColors.primaryButtonGradientStart,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await ref.read(eventsProvider.notifier).syncAndRefresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final isScrolled = constraints.scrollOffset > 0;
            return SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: isScrolled
                  ? AppColors.gradientStart
                  : Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 3.0,
              automaticallyImplyLeading: false,
              toolbarHeight: 53.h,
              titleSpacing: 0,
              title: Column(
                children: [
                  SizedBox(height: 12.h),
                  showBackButton
                      ? AppBar2(title: texts.myEvents)
                      : AppBar1(title: texts.myEvents),
                ],
              ),
            );
          },
        ),
        if (!isLoggedIn) ...[
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    texts.loginPrompt,
                    style: AppTextStyles.roboto400Regular20(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    text: texts.loginAction,
                    onPressed: () {
                      context.pushNamed(AppRoute.login.name);
                    },
                  ),
                ],
              ),
            ),
          )
        ] else if (hasAnyEvents)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasCustomEvents) ...[
                  SizedBox(height: 24.h),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: customEvents.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final event = customEvents[index];
                      return MyEventCard(
                        date: DateFormat(
                          'MMM dd, yyyy',
                        ).format(event.date).toUpperCase(),
                        title: event.title,
                        reminder: event.reminder,
                        onEdit: () {
                          AddEventBottomSheet.show(
                            context,
                            eventToEdit: event,
                          );
                        },
                        onRemove: () {
                          ref.read(eventsProvider.notifier).deleteEvent(event.id);
                        },
                      );
                    },
                  ),
                ],
                if (hasSystemEvents) ...[
                  SizedBox(height: hasCustomEvents ? 40.h : 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      texts.upcomingOccasions,
                      style: AppTextStyles.colitez400Italic24(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: systemEvents.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final event = systemEvents[index];
                      return UpcomingOccasionCard(
                        date: DateFormat(
                          'MMM dd, yyyy',
                        ).format(event.date).toUpperCase(),
                        title: event.title,
                      );
                    },
                  ),
                ],
                SizedBox(height: 80.h),
              ],
            ),
          )
        else
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.eventsEmpty,
                  width: 150.w,
                  height: 180.h,
                ),
                SizedBox(height: 24.h),
                Text(
                  texts.noEventsHere,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.colitez400Italic32(),
                ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
      ],)
    );

    if (showBackButton) {
      return GradientScaffold(floatingActionButton: fab, body: content);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: content,
      floatingActionButton: fab,
    );
  }
}