import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/animated_like_button.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../favorites/domain/entities/favorite_entity.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../../features/payments/presentation/providers/payment_providers.dart';
import '../../../../features/payments/presentation/providers/payment_controller.dart';
import 'package:daimond/l10n/app_localizations.dart';
import '../widgets/card_detail_carousel.dart';
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
    final message = useState(initialMessage ?? "Your message here");
    final currentPage = useState(0);
    final quantity = useState(1);
    final pageController = usePageController();

    final fromController = useTextEditingController();
    final toController = useTextEditingController();
    final fromFocusNode = useFocusNode();
    final toFocusNode = useFocusNode();

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final texts = AppLocalizations.of(context)!;

    final isFavoriteAsync = ref.watch(isFavoriteProvider(cardId));
    final isFavorite = isFavoriteAsync.valueOrNull ?? false;

    final offeringsAsync = ref.watch(offeringsProvider);
    final paymentState = ref.watch(paymentControllerProvider);
    final customerInfo = ref.watch(customerInfoStreamProvider).valueOrNull;
    final hasActiveSubscription = customerInfo?.entitlements.active.containsKey('premium') ?? false;

    final cardDetailState = ref.watch(cardDetailControllerProvider);

    useEffect(() {
      void listener() {
        message.value = textController.text;
      }

      textController.addListener(listener);
      return () => textController.removeListener(listener);
    }, [textController]);

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
                      AppBar2(title: texts.cardDetails),
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

                    if (currentPage.value < 2) ...[
                      // Title and Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                      // Buttons Section

                      // Row 1: Quantity and Preview
                      Row(
                        children: [
                          // Quantity Selector
                          Container(
                            height: 44.h,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (quantity.value > 1) quantity.value--;
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    child: Text(
                                      '-',
                                      style: AppTextStyles.colitez400Italic22(),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${quantity.value}',
                                  style: AppTextStyles.colitez400Italic22(),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    quantity.value++;
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    child: Text(
                                      '+',
                                      style: AppTextStyles.colitez400Italic22(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // Preview Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                if (textController.text.trim().isEmpty) {
                                  CustomSnackbar.showError(
                                    context,
                                    texts.pleaseEnterMessage,
                                  );
                                  return;
                                }
                                if (fromController.text.trim().isEmpty ||
                                    toController.text.trim().isEmpty) {
                                  CustomSnackbar.showError(
                                    context,
                                    texts.pleaseFillRecipientFields,
                                  );
                                  pageController.animateToPage(
                                    2,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  return;
                                }
                                context.pushNamed(
                                  AppRoute.previewCard.name,
                                  extra: {'message': message.value},
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                fixedSize: Size.fromHeight(44.h),
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 0.5.w,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              child: Text(
                                texts.preview,
                                style: AppTextStyles.colitez400Italic22(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),

                      // Row 2: Continue and Heart
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              text: texts.continueBtn,
                              isLoading: cardDetailState.isLoading,
                              onPressed: cardDetailState.isLoading ? null : () {
                                ref.read(cardDetailControllerProvider.notifier).handlePurchaseAndOrder(
                                  context: context,
                                  cardId: cardId,
                                  title: title,
                                  message: textController.text,
                                  from: fromController.text,
                                  to: toController.text,
                                  texts: texts,
                                  pageController: pageController,
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
                                              0xFFFFA7A7, // Default to AppColors.card1
                                          supabaseUserId: 'dummy_user_uid',
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
                          side: BorderSide(color: Colors.black, width: 0.5.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          texts.customizeCard,
                          style: AppTextStyles.colitez400Italic22(),
                        ),
                      ),
                    ] else ...[
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                texts.addRecipient,
                                style: AppTextStyles.colitez400Italic24(),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            AppTextField(
                              labelText: texts.fromLabel,
                              hintText: texts.fromHint,
                              controller: fromController,
                              focusNode: fromFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  toFocusNode.requestFocus(),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? texts.thisFieldIsRequired
                                  : null,
                            ),
                            SizedBox(height: 24.h),
                            AppTextField(
                              labelText: texts.toLabel,
                              hintText: texts.toHint,
                              controller: toController,
                              focusNode: toFocusNode,
                              textInputAction: TextInputAction.done,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? texts.thisFieldIsRequired
                                  : null,
                            ),
                            SizedBox(height: 32.h),
                            PrimaryButton(
                              text: texts.sendButton,
                              isLoading: cardDetailState.isLoading,
                              onPressed: cardDetailState.isLoading ? null : () {
                                if (formKey.currentState?.validate() ?? false) {
                                  ref.read(cardDetailControllerProvider.notifier).handlePurchaseAndOrder(
                                    context: context,
                                    cardId: cardId,
                                    title: title,
                                    message: textController.text,
                                    from: fromController.text,
                                    to: toController.text,
                                    texts: texts,
                                    pageController: pageController,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
