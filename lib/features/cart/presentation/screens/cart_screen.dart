import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';

class CartScreen extends HookConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemsAsync = ref.watch(cartProvider);
    final texts = AppLocalizations.of(context)!;

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            AppBar2(title: texts.myCart),
            SizedBox(height: 24.h),
            Expanded(
              child: cartItemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'Your cart is empty',
                        style: AppTextStyles.roboto400Regular16().copyWith(color: Colors.black54),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.pushNamed(
                            AppRoute.cardDetail.name,
                            extra: {
                              'cardId': item.cardId,
                              'title': item.title,
                              'cartItemId': item.id,
                              'initialMessage': item.message,
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.black, width: 0.5.w),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.gatta,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: AppTextStyles.roboto500Medium14(),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      item.message,
                                      style: AppTextStyles.roboto400Regular13().copyWith(color: Colors.black54),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ConfirmationDialog(
                                      title: 'Remove from Cart',
                                      message: 'Are you sure you want to remove this item from your cart?',
                                      confirmText: 'Remove',
                                      cancelText: 'Cancel',
                                      onConfirm: () {
                                        Navigator.of(context).pop();
                                        if (item.id != null) {
                                          ref.read(cartProvider.notifier).removeFromCart(item.id!);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
            cartItemsAsync.maybeWhen(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
                  child: PrimaryButton(
                    text: 'Checkout (${items.length})',
                    onPressed: () {
                      // Checkout action
                    },
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
