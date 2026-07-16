import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../widgets/notification_card.dart';
import '../providers/notifications_provider.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.isNegative) return '0m';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final groupedAsync = ref.watch(groupedNotificationsProvider);

    // Trigger sync
    ref.watch(syncNotificationsProvider);

    return GradientScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final isScrolled = constraints.scrollOffset > 0;
                return SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: isScrolled
                      ? const Color(0xFFE7FFEC)
                      : Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 3.0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 60.h,
                  titleSpacing: 0,
                  title: Column(
                    children: [
                      SizedBox(height: 12.h),
                      AppBar2(title: texts.notificationsTitle),
                    ],
                  ),
                );
              },
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            groupedAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('${texts.errorOccurred}$err')),
              ),
              data: (grouped) {
                if (grouped.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        texts.noNotificationsYet,
                        style: AppTextStyles.roboto300Light13(),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final rawTitle = grouped.keys.elementAt(index);
                      final items = grouped[rawTitle]!;

                      String displayTitle = rawTitle;
                      if (rawTitle == 'today_key') {
                        displayTitle = texts.today;
                      } else if (rawTitle == 'yesterday_key') {
                        displayTitle = texts.yesterday;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (rawTitle != 'today_key') ...[
                            Text(
                              displayTitle,
                              style: AppTextStyles.roboto500Medium14(),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          ...items.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: NotificationCard(
                                title: item.title,
                                description: item.description,
                                time: _getTimeAgo(item.createdAt),
                                isRead: item.isRead,
                                onTap: () {
                                  // 1. Mark as read immediately for snappy UI
                                  if (item.id != null && !item.isRead) {
                                    ref.read(notificationsRepositoryProvider).markAsRead(item.id!);
                                  }
                                  
                                  // 2. Wait 250ms so user sees the ripple effect and state change
                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    if (!context.mounted) return;

                                    // Robust Keyword Routing Fallback
                                    String targetRoute = '/main'; // Safe global fallback
                                    final search = '${item.title.toLowerCase()} ${item.description.toLowerCase()}';
                                    
                                    if (search.contains('event') || search.contains('reminder')) {
                                      targetRoute = '/events';
                                    } else if (search.contains('card') || search.contains('design')) {
                                      targetRoute = '/cards';
                                    } else if (search.contains('order') || search.contains('purchas') || search.contains('payment')) {
                                      targetRoute = '/order-history';
                                    } else if (search.contains('subscription') || search.contains('plan') || search.contains('offer')) {
                                      targetRoute = '/subscription';
                                    } else if (search.contains('draft')) {
                                      targetRoute = '/my-drafts';
                                    }

                                    final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
                                    
                                    // 3. Use go() instead of push() to prevent duplicate stack building
                                    if (currentPath != targetRoute) {
                                      context.go(targetRoute);
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      );
                    }, childCount: grouped.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
