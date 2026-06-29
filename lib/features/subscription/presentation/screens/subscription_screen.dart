import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';

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

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            AppBar2(title: texts.subscriptions),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
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
                    price: texts.plan1Price,
                    isSelected: selectedPlan.value == 0,
                    onTap: () => selectedPlan.value = 0,
                  ),
                  SizedBox(height: 24.h),
                  SubscriptionPlanCard(
                    title: texts.plan2Title,
                    description: texts.plan2Desc,
                    cardsCount: texts.plan2Cards,
                    price: texts.plan2Price,
                    isSelected: selectedPlan.value == 1,
                    onTap: () => selectedPlan.value = 1,
                  ),
                  SizedBox(height: 40.h),

                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
                  child: PrimaryButton(
                    text: texts.subscribeButton,
                    onPressed: () {
                      // TODO: Implement subscription logic
                    },
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
                        onTap: () {},
                        child: Text(
                          texts.restorePurchases,
                          style: AppTextStyles.roboto500Medium14().copyWith(
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          texts.termsOfService,
                          style: AppTextStyles.roboto500Medium14().copyWith(
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () {},
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
