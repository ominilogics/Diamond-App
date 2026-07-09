import 'package:daimond/features/cards/presentation/providers/cards_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_provider.dart';
import 'package:collection/collection.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderHistoryScreen extends HookConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);
    final texts = AppLocalizations.of(context)!;

    final allCardsState = ref.watch(allCardsStreamProvider);
    final allCards = allCardsState.valueOrNull ?? [];

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
                      AppBar2(title: texts.orderHistory),
                    ],
                  ),
                );
              },
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ordersAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppAssets.cart,
                            width: 140.w,
                            height: 140.h,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            texts.emptyOrderHistory,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.colitez400Italic32(
                              color: Colors.black,
                              letterSpacing: 32.0 * -0.03,
                            ),
                          ),
                          SizedBox(height: 80.h),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = items[index];
                      final card = allCards.firstWhereOrNull(
                        (c) => c.id == item.cardId,
                      );
                      final hasImage =
                          card != null && card.coverImageUrl.isNotEmpty;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context.pushNamed(
                              AppRoute.cardDetail.name,
                              extra: {
                                'cardId': item.cardId,
                                'title': item.title,
                                'orderId': item.id,
                                'initialMessage': item.message,
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(0xFF000000),
                                width: 0.5.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                hasImage
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: card!.coverImageUrl,
                                          width: 60.w,
                                          height: 60.w,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        AppAssets.gatta,
                                        width: 60.w,
                                        height: 60.w,
                                        fit: BoxFit.cover,
                                      ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style:
                                            AppTextStyles.roboto500Medium14(),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        item.message,
                                        style:
                                            AppTextStyles.roboto400Regular13()
                                                .copyWith(
                                                  color: Colors.black54,
                                                ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: items.length),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
