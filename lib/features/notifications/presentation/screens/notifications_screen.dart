import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../widgets/notification_card.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  String _getTimeAgo(BuildContext context, DateTime date) {
    final texts = AppLocalizations.of(context)!;
    final difference = DateTime.now().difference(date);
    if (difference.isNegative || difference.inMinutes < 1) {
      return texts.now;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 7).floor()}w';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final groupedAsync = ref.watch(groupedNotificationsProvider);

    // Trigger sync
    ref.watch(syncNotificationsProvider);

    useEffect(() {
      Future.microtask(() => ref.read(lastOpenedNotificationsProvider.notifier).markOpened());
      return null;
    }, const []);

    final scrollController = useScrollController();
    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
           final currentLimit = ref.read(notificationsLimitProvider);
           final asyncState = ref.read(groupedNotificationsProvider);
           
           if (!asyncState.isLoading && asyncState.hasValue) {
             final currentItemsCount = asyncState.value!.values.fold<int>(0, (prev, list) => prev + list.length);
             // Only increase limit if we actually maxed out the current limit
             if (currentItemsCount >= currentLimit) {
               ref.read(notificationsLimitProvider.notifier).state = currentLimit + 20;
             }
           }
        }
      }
      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return GradientScaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
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
            if (groupedAsync.hasValue)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                sliver: groupedAsync.value!.isEmpty 
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text(
                          texts.noNotificationsYet,
                          style: AppTextStyles.roboto300Light13(),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final rawTitle = groupedAsync.value!.keys.elementAt(index);
                        final items = groupedAsync.value![rawTitle]!;

                      String displayTitle = rawTitle;
                      if (rawTitle == 'newNotifications') {
                        displayTitle = texts.newNotifications;
                      } else if (rawTitle == 'earlierNotifications') {
                        displayTitle = texts.earlierNotifications;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            style: AppTextStyles.roboto500Medium14(),
                          ),
                          SizedBox(height: 16.h),
                          ...items.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: NotificationCard(
                                title: item.title,
                                description: item.description,
                                time: _getTimeAgo(context, item.createdAt),
                                isRead: item.isRead,
                                onTrailingTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
                                    builder: (context) {
                                      return SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (!item.isRead)
                                              ListTile(
                                                leading: const Icon(Icons.mark_email_read),
                                                title: Text(texts.markAsRead),
                                                onTap: () {
                                                  if (item.id != null) {
                                                    ref.read(notificationsRepositoryProvider).markAsRead(item.id!);
                                                  }
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ListTile(
                                              leading: const Icon(Icons.delete_outline, color: Colors.red),
                                              title: Text(texts.deleteNotification, style: const TextStyle(color: Colors.red)),
                                              onTap: () {
                                                if (item.id != null) {
                                                  ref.read(notificationsRepositoryProvider).deleteNotification(item.id!);
                                                }
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                onTap: () {
                                  // 1. Mark as read immediately for snappy UI
                                  if (item.id != null && !item.isRead) {
                                    ref.read(notificationsRepositoryProvider).markAsRead(item.id!);
                                  }
                                  
                                  // 2. Wait 250ms so user sees the ripple effect and state change
                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    if (!context.mounted) return;

                                    String targetRoute = '/main'; // Safe global fallback
                                    // Use explicit payload if available
                                    if (item.payload != null && item.payload!.isNotEmpty) {
                                      targetRoute = item.payload!;
                                      // Backward compatibility for legacy payloads already in the database
                                      if (targetRoute == '/events') {
                                        targetRoute = '/main?tab=1';
                                      }
                                    } else {
                                      // Robust Keyword Routing Fallback
                                      final search = '${item.title.toLowerCase()} ${item.description.toLowerCase()}';
                                      
                                      if (search.contains('event') || search.contains('reminder')) {
                                        targetRoute = '/main?tab=1';
                                      } else if (search.contains('card') || search.contains('design')) {
                                        targetRoute = '/cards';
                                      } else if (search.contains('order') || search.contains('purchas') || search.contains('payment')) {
                                        targetRoute = '/orderHistory';
                                      } else if (search.contains('subscription') || search.contains('plan') || search.contains('offer')) {
                                        targetRoute = '/subscription';
                                      } else if (search.contains('draft')) {
                                        targetRoute = '/my-drafts';
                                      }
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
                      }, childCount: groupedAsync.value!.length),
                    ),
              )
            else if (groupedAsync.hasError)
              SliverFillRemaining(
                child: Center(child: Text('${texts.errorOccurred}${groupedAsync.error}')),
              )
            else
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
