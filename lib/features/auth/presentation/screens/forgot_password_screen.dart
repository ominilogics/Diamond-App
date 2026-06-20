import 'package:daimond/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_labelled_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final texts = AppLocalizations.of(context)!;

    void onSendPressed() {
      if (formKey.currentState!.validate()) {
        // Proceed with password reset
      }
    }

    return GradientScaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: formKey,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 36.h),
                Text(
                  texts.forgotPasswordTitle,
                  style: AppTextStyles.colitez400Italic32(),
                ),
                SizedBox(height: 9.h),
                Text(
                  texts.forgotPasswordSubtitle,
                  style: AppTextStyles.roboto300Light13(),
                ),
                SizedBox(height: 29.h),

                AppLabelledTextField(
                  label: texts.emailLabel,
                  hintText: texts.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: AppValidators.validateEmail,
                ),

                SizedBox(height: 35.h),

                PrimaryButton(text: texts.sendButton, onPressed: onSendPressed),
                
                SizedBox(height: 24.h),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.goNamed(AppRoute.login.name);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: texts.rememberPassword,
                        style: AppTextStyles.roboto300Light13(),
                        children: [
                          TextSpan(
                            text: texts.logIn,
                            style: AppTextStyles.roboto400Regular13(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
          ),
        ],
      ),
    );
  }
}
