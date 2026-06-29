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

class OrderHistoryScreen extends HookConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);
    final texts = AppLocalizations.of(context)!;

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            AppBar2(title: texts.orderHistory),
            SizedBox(height: 24.h),
            Expanded(
              child: ordersAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
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
                            border: Border.all(color: const Color(0xFF000000), width: 0.5.w),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.gatta,
                                width: 60.w,
                                height: 60.w,
                                fit: BoxFit.contain,
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
                                      title: 'Remove Order',
                                      message: 'Are you sure you want to remove this order from your history?',
                                      confirmText: 'Remove',
                                      cancelText: 'Cancel',
                                      onConfirm: () {
                                        Navigator.of(context).pop();
                                        if (item.id != null) {
                                          ref.read(orderProvider.notifier).removeOrder(item.id!);
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
          ],
        ),
      ),
    );
  }
}
