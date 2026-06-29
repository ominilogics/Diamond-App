import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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

class CardDetailScreen extends HookConsumerWidget {
  final String cardId;
  final String title;
  final int? orderId;
  final String? initialMessage;
  final int? cardColorValue;

  const CardDetailScreen({
    super.key,
    required this.cardId,
    required this.title,
    this.orderId,
    this.initialMessage,
    this.cardColorValue,
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

    final isFavoriteAsync = ref.watch(isFavoriteProvider(cardId));
    final isFavorite = isFavoriteAsync.valueOrNull ?? false;


    useEffect(() {
      void listener() {
        message.value = textController.text;
      }

      textController.addListener(listener);
      return () => textController.removeListener(listener);
    }, [textController]);

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            const AppBar2(title: 'Card Details'),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      // Carousel for Front and Back
                      Container(
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
                        child: PageView(
                          controller: pageController,
                          onPageChanged: (index) {
                            currentPage.value = index;
                          },
                          children: [
                            // Front Side
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.gatta,
                                    fit: BoxFit.contain,
                                    width: 253.w,
                                    height: 358.h,
                                  ),
                                  Text(
                                    'Front Cover Design',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.colitez400Italic32(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Back Side (Editable Message)
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.gatta,
                                    fit: BoxFit.contain,
                                    width: 253.w,
                                    height: 358.h,
                                  ),
                                  SizedBox(
                                    width: 200.w, // Limit text field width
                                    child: TextField(
                                      controller: textController,
                                      textAlign: TextAlign.center,
                                      maxLines: null,
                                      style: AppTextStyles.colitez400Italic32(
                                        color: Colors.black,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Type your message...',
                                        hintStyle: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Envelope / Third Step
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.gatta,
                                    fit: BoxFit.contain,
                                    width: 253.w,
                                    height: 358.h,
                                  ),
                                  Text(
                                    'Envelope Design',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.colitez400Italic32(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Carousel Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = currentPage.value == index;
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
                          "Loving you has been one of life's greatest gifts. No matter where life takes us, my heart will always find its way back to you.",
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
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                      child: Text('-', style: AppTextStyles.colitez400Italic22()),
                                    ),
                                  ),
                                  Text('${quantity.value}', style: AppTextStyles.colitez400Italic22()),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      quantity.value++;
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                      child: Text('+', style: AppTextStyles.colitez400Italic22()),
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
                                    CustomSnackbar.showError(context, 'Please enter a message for the card.');
                                    return;
                                  }
                                  if (fromController.text.trim().isEmpty || toController.text.trim().isEmpty) {
                                    CustomSnackbar.showError(context, 'Please fill out all recipient fields.');
                                    pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                                  'Preview',
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
                                text: 'Continue',
                                onPressed: () {
                                  if (textController.text.trim().isEmpty) {
                                    CustomSnackbar.showError(context, 'Please enter a message for the card.');
                                    return;
                                  }
                                  if (fromController.text.trim().isEmpty || toController.text.trim().isEmpty) {
                                    CustomSnackbar.showError(context, 'Please fill out all recipient fields.');
                                    pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                    return;
                                  }
                                  final order = OrderEntity(
                                    cardId: cardId,
                                    title: title,
                                    message: message.value,
                                    addedAt: DateTime.now(),
                                  );
                                  ref.read(orderProvider.notifier).addOrder(order);
                                  CustomSnackbar.showSuccess(context, 'Order Placed');

                                  Future.delayed(const Duration(milliseconds: 1000), () {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      context.pushNamed(AppRoute.orderHistory.name);
                                    }
                                  });
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
                                    ref.read(favoritesProvider.notifier).toggleFavorite(
                                      FavoriteEntity(
                                        cardId: cardId,
                                        title: title,
                                        colorValue: cardColorValue ?? 0xFFFFA7A7, // Default to AppColors.card1
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
                              extra: {'cardId': cardId},
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
                            'Customize Card',
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
                                child: Text('Add Recipient', style: AppTextStyles.colitez400Italic24()),
                              ),
                              SizedBox(height: 24.h),
                              AppTextField(
                                labelText: 'From',
                                hintText: 'Enter your name here.',
                                controller: fromController,
                                focusNode: fromFocusNode,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) => toFocusNode.requestFocus(),
                                validator: (value) => value == null || value.trim().isEmpty ? 'This field is required' : null,
                              ),
                              SizedBox(height: 24.h),
                              AppTextField(
                                labelText: 'To',
                                hintText: "Enter recipient's name here.",
                                controller: toController,
                                focusNode: toFocusNode,
                                textInputAction: TextInputAction.done,
                                validator: (value) => value == null || value.trim().isEmpty ? 'This field is required' : null,
                              ),
                              SizedBox(height: 32.h),
                              PrimaryButton(
                                text: 'Send',
                                onPressed: () {
                                  if (formKey.currentState?.validate() ?? false) {
                                    // Handle send logic here
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
            ),
          ],
        ),
      ),
    );
  }
}
