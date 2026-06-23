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
import '../../../../core/widgets/gradient_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class CardDetailScreen extends HookConsumerWidget {
  final String cardId;
  final String title;
  final int? cartItemId;
  final String? initialMessage;

  const CardDetailScreen({
    super.key,
    required this.cardId,
    required this.title,
    this.cartItemId,
    this.initialMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController(text: initialMessage ?? "Your message here");
    final message = useState(initialMessage ?? "Your message here");
    final currentPage = useState(0);
    
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
                      SizedBox(
                        width: double.infinity,
                        height: 450.h,
                        child: PageView(
                          onPageChanged: (index) {
                            currentPage.value = index;
                          },
                          children: [
                            // Front Side (Cover)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.gatta,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: 450.h,
                                ),
                                Positioned.fill(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                                      child: Text(
                                        'Front Cover Design',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.colitez400Italic32(
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Back Side (Editable Message)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.gatta,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: 450.h,
                                ),
                                Positioned.fill(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 32.w),
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
                                          hintStyle: TextStyle(color: Colors.black54),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (index) {
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
                      // Preview and Purchase Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.pushNamed(
                                  AppRoute.previewCard.name,
                                  extra: {'message': message.value},
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                fixedSize: Size.fromHeight(44.h),
                                side: BorderSide(color: Colors.black, width: 0.5.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                              child: Text(
                                'Preview',
                                style: AppTextStyles.colitez400Italic22(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: PrimaryButton(
                              text: cartItemId != null ? 'Save Changes' : 'Add to Cart',
                              onPressed: () {
                                if (cartItemId != null) {
                                  final cartItem = CartItemEntity(
                                    id: cartItemId,
                                    cardId: cardId,
                                    title: title,
                                    message: message.value,
                                    addedAt: DateTime.now(),
                                  );
                                  ref.read(cartProvider.notifier).addToCart(cartItem);
                                  GradientSnackbar.show(context, 'Changes Saved');

                                  Future.delayed(const Duration(milliseconds: 1000), () {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      context.pop();
                                    }
                                  });
                                } else {
                                  final cartItem = CartItemEntity(
                                    cardId: cardId,
                                    title: title,
                                    message: message.value,
                                    addedAt: DateTime.now(),
                                  );
                                  ref.read(cartProvider.notifier).addToCart(cartItem);
                                  GradientSnackbar.show(context, 'Added to Cart');

                                  Future.delayed(const Duration(milliseconds: 1000), () {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      context.pushNamed(AppRoute.cart.name);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
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
