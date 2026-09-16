import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:collection/collection.dart';
import 'package:daimond/features/payments/presentation/providers/payment_providers.dart';
import 'package:daimond/features/payments/presentation/providers/payment_controller.dart';
import 'package:daimond/core/widgets/custom_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:daimond/core/routing/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/subscription_plan_card.dart';

class SubscriptionScreen extends HookConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;

    // 0 = Standard, 1 = Premium
    final selectedPlan = useState<int>(1);

    final offeringsAsync = ref.watch(offeringsProvider);
    final paymentState = ref.watch(paymentControllerProvider);

    final availablePackages = offeringsAsync.valueOrNull?.current?.availablePackages ?? [];
    final standardPackage = availablePackages.firstWhereOrNull((p) => p.identifier == 'standard_plan');
    final proPackage = availablePackages.firstWhereOrNull((p) => p.identifier == 'pro_plan');

    final customerInfo = ref.watch(customerInfoStreamProvider).valueOrNull;
    final activeSubscriptions = customerInfo?.activeSubscriptions ?? [];
    
    final standardProductId = standardPackage?.storeProduct.identifier;
    final proProductId = proPackage?.storeProduct.identifier;

    bool isSubscribedTo(String? productId) {
      if (productId == null) return false;
      final baseId = productId.split(':').first;
      return activeSubscriptions.any(
        (sub) => sub == productId || sub.split(':').first == baseId,
      );
    }

    final hasStandard = isSubscribedTo(standardProductId);
    final hasPro = isSubscribedTo(proProductId);
    final isSubscribed = hasStandard || hasPro || (customerInfo?.entitlements.active.isNotEmpty ?? false);

    useEffect(() {
      if (hasPro) {
        selectedPlan.value = 1;
      } else if (hasStandard) {
        selectedPlan.value = 0;
      }
      return null;
    }, [hasPro, hasStandard]);

    String getButtonText() {
      if (selectedPlan.value == 0) {
        if (hasStandard) return 'Current Plan';
        if (hasPro) return 'Downgrade';
        return texts.subscribeButton;
      } else {
        if (hasPro) return 'Current Plan';
        if (hasStandard) return 'Upgrade to Pro';
        return texts.subscribeButton;
      }
    }

    bool isButtonDisabled() {
      if (paymentState.isLoading) return true;
      if (selectedPlan.value == 0 && hasStandard) return true;
      if (selectedPlan.value == 1 && hasPro) return true;
      return false;
    }

    final plan1PriceText = standardPackage?.storeProduct.priceString ?? texts.plan1Price;
    final plan2PriceText = proPackage?.storeProduct.priceString ?? texts.plan2Price;

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                            AppBar2(title: texts.subscriptions),
                          ],
                        ),
                      );
                    },
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: 24.h),
                        Text(
                          texts.subscriptionHeading,
                          style: AppTextStyles.colitez400Italic32().copyWith(
                            color: Colors.black,
                            fontSize: 32.sp,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          texts.subscriptionSubheading,
                          style: AppTextStyles.roboto400Regular16().copyWith(
                            color: const Color(0xFF616161),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        SubscriptionPlanCard(
                          title: texts.plan1Title,
                          description: texts.plan1Desc,
                          cardsCount: texts.plan1Cards,
                          price: plan1PriceText,
                          isSelected: selectedPlan.value == 0,
                          onTap: () => selectedPlan.value = 0,
                        ),
                        SizedBox(height: 24.h),
                        SubscriptionPlanCard(
                          title: texts.plan2Title,
                          description: texts.plan2Desc,
                          cardsCount: texts.plan2Cards,
                          price: plan2PriceText,
                          isSelected: selectedPlan.value == 1,
                          onTap: () => selectedPlan.value = 1,
                        ),
                        SizedBox(height: 40.h),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
                    child: PrimaryButton(
                      text: getButtonText(),
                      isLoading: paymentState.isLoading,
                      onPressed: isButtonDisabled() ? null : () {
                        final packageToBuy = selectedPlan.value == 0 ? standardPackage : proPackage;
                        if (packageToBuy != null) {
                          ref.read(paymentControllerProvider.notifier).purchase(context, packageToBuy);
                        } else {
                          CustomSnackbar.showError(context, texts.storeNotReady);
                        }
                      },
                    ),
                  ),
                  if (isSubscribed)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(paymentControllerProvider.notifier).manageSubscriptions(context);
                        },
                        child: Text(
                          texts.manageSubscriptions,
                          style: AppTextStyles.roboto500Medium14().copyWith(
                            color: const Color(0xFF3B82F6), // Premium accent color for action
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      texts.subscriptionGuarantee,
                      style: AppTextStyles.roboto400Regular12().copyWith(
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 32.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref.read(paymentControllerProvider.notifier).restorePurchases(context);
                          },
                          child: Text(
                            texts.restorePurchases,
                            style: AppTextStyles.roboto500Medium14().copyWith(
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(AppRoute.termsAndConditions.name);
                          },
                          child: Text(
                            texts.termsOfService,
                            style: AppTextStyles.roboto500Medium14().copyWith(
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(AppRoute.privacyPolicy.name);
                          },
                          child: Text(
                            texts.privacyPolicy,
                            style: AppTextStyles.roboto500Medium14().copyWith(
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }
}
