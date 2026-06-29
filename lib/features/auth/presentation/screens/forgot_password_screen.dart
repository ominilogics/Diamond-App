import 'package:daimond/core/routing/app_router.dart';
import 'package:daimond/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_labelled_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final emailFocus = useFocusNode();
    final texts = AppLocalizations.of(context)!;

    final isLoading = ref.watch(authProvider);

    void onSendPressed() {
      if (formKey.currentState!.validate()) {
        final email = emailController.text.trim();
        debugPrint('Forgot Password reset link requested for email: $email');

        ref
            .read(authProvider.notifier)
            .resetPassword(
              email,
              (errorMessage) {
                debugPrint('Forgot Password reset link failed: $errorMessage');
                if (context.mounted) {
                  CustomSnackbar.showError(context, errorMessage);
                }
              },
              () {
                debugPrint('Forgot Password reset link sent successfully to email: $email');
                if (context.mounted) {
                  CustomSnackbar.showSuccess(
                    context,
                    texts.forgotPasswordSuccess,
                  );
                  context.goNamed(AppRoute.login.name);
                }
              },
            );
      } else {
        debugPrint('Forgot Password validation failed');
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
                      focusNode: emailFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onSendPressed(),
                      validator: AppValidators.validateEmail,
                    ),

                    SizedBox(height: 35.h),

                    PrimaryButton(
                      text: texts.sendButton,
                      onPressed: onSendPressed,
                      isLoading: isLoading,
                    ),

                    SizedBox(height: 16.h),

                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.goNamed(AppRoute.login.name);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                          child: RichText(
                            text: TextSpan(
                              text: texts.rememberPassword,
                              style: AppTextStyles.roboto300Light14(),
                              children: [
                                TextSpan(
                                  text: texts.logIn,
                                  style: AppTextStyles.roboto400Regular14(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
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
