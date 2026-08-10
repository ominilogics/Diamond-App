import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/animated_like_button.dart';
import '../../../favorites/domain/entities/favorite_entity.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import 'package:daimond/l10n/app_localizations.dart';
import '../widgets/card_detail_carousel.dart';
import '../widgets/recipient_delivery_form.dart';
import '../providers/card_detail_controller.dart';

class CardDetailScreen extends HookConsumerWidget {
  final String cardId;
  final String title;
  final int? orderId;
  final String? initialMessage;
  final int? cardColorValue;
  final String? coverImageUrl;
  final String? frontMessage;

  const CardDetailScreen({
    super.key,
    required this.cardId,
    required this.title,
    this.orderId,
    this.initialMessage,
    this.cardColorValue,
    this.coverImageUrl,
    this.frontMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController(
      text: initialMessage ?? "Your message here",
    );
    final currentPage = useState(0);
    final pageController = usePageController();

    final fromController = useTextEditingController();
    final toController = useTextEditingController();
    final texts = AppLocalizations.of(context)!;


    final isFavoriteAsync = ref.watch(isFavoriteProvider(cardId));
    final isFavorite = isFavoriteAsync.valueOrNull ?? false;

    final cardDetailState = ref.watch(cardDetailControllerProvider);

    void handleBackNavigation() {
      if (currentPage.value == 2) {
        pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }
      context.pop();
    }

    return PopScope(
      canPop: currentPage.value != 2,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        handleBackNavigation();
      },
      child: GradientScaffold(
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
                        AppBar2(
                          title: texts.cardDetails,
                          onBackPressed: handleBackNavigation,
                        ),
                      ],
                    ),
                  );
                },
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    CardDetailCarousel(
                      pageController: pageController,
                      currentPage: currentPage.value,
                      onPageChanged: (index) => currentPage.value = index,
                      coverImageUrl: coverImageUrl,
                      frontMessage: frontMessage,
                      textController: textController,
                    ),
                    SizedBox(height: 24.h),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topLeft,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: currentPage.value < 2
                          ? Column(
                              key: const ValueKey('step_1_2_content'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and Price Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      style: AppTextStyles.colitez400Italic24(),
                                    ),
                                    Text(
                                      '\$ 5.99',
                                      style: AppTextStyles.colitez400Italic24(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),

                                // Description
                                Text(
                                  texts.defaultCardDescription,
                                  style: AppTextStyles.roboto300Light13(),
                                ),
                                SizedBox(height: 24.h),

                                // Continue and Heart Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        text: texts.continueBtn,
                                        isLoading: cardDetailState.isLoading,
                                        onPressed: cardDetailState.isLoading
                                            ? null
                                            : () {
                                                ref
                                                    .read(
                                                      cardDetailControllerProvider
                                                          .notifier,
                                                    )
                                                    .handlePurchaseAndOrder(
                                                      context: context,
                                                      cardId: cardId,
                                                      title: title,
                                                      message:
                                                          textController.text,
                                                      from: fromController.text,
                                                      to: toController.text,
                                                      texts: texts,
                                                      pageController:
                                                          pageController,
                                                    );
                                              },
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    // Heart Button
                                    Container(
                                      width: 44.w,
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 0.5.w,
                                        ),
                                      ),
                                      child: Center(
                                        child: AnimatedLikeButton(
                                          isLiked: isFavorite,
                                          onTap: () {
                                            ref
                                                .read(favoritesProvider.notifier)
                                                .toggleFavorite(
                                                  FavoriteEntity(
                                                    cardId: cardId,
                                                    title: title,
                                                    colorValue:
                                                        cardColorValue ??
                                                        0xFFFFA7A7,
                                                    supabaseUserId:
                                                        'dummy_user_uid',
                                                    favoritedAt: DateTime.now(),
                                                  ),
                                                );
                                          },
                                          size: 22.w,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                // Row 3: Customize Card
                                OutlinedButton(
                                  onPressed: () {
                                    context.pushNamed(
                                      AppRoute.editCard.name,
                                      extra: {
                                        'cardId': cardId,
                                        'coverImageUrl': coverImageUrl,
                                        'frontMessage': frontMessage,
                                        'initialMessage': initialMessage,
                                      },
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(double.infinity, 44.h),
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: 0.5.w,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                  ),
                                  child: Text(
                                    texts.customizeCard,
                                    style: AppTextStyles.colitez400Italic22(),
                                  ),
                                ),
                              ],
                            )
                          : KeyedSubtree(
                              key: const ValueKey('step_3_content'),
                              child: RecipientDeliveryForm(
                                isLoading: cardDetailState.isLoading,
                                onSendPressed: (e164Phone, deliveryMethod) {
                                  ref
                                      .read(
                                        cardDetailControllerProvider.notifier,
                                      )
                                      .handlePurchaseAndOrder(
                                        context: context,
                                        cardId: cardId,
                                        title: title,
                                        message: textController.text,
                                        from: fromController.text,
                                        to: toController.text,
                                        texts: texts,
                                        pageController: pageController,
                                        recipientPhone: e164Phone,
                                        deliveryMethod: deliveryMethod,
                                        coverImageUrl: coverImageUrl,
                                        frontMessage: frontMessage,
                                      );
                                },
                              ),
                            ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}


