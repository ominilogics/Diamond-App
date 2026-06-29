import 'package:daimond/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_labelled_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/or_divider.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/utils/app_assets.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final nameFocus = useFocusNode();
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final confirmPasswordFocus = useFocusNode();
    final texts = AppLocalizations.of(context)!;

    final isLoading = ref.watch(authProvider);

    void onSignUpPressed() {
      if (formKey.currentState!.validate()) {
        debugPrint('Sign Up process started for email: ${emailController.text.trim()}');
        ref
            .read(authProvider.notifier)
            .signUp(
              emailController.text.trim(),
              passwordController.text.trim(),
              nameController.text.trim(),
              (errorMessage) {
                debugPrint('Sign Up failed: $errorMessage');
                if (context.mounted) {
                  CustomSnackbar.showError(context, errorMessage);
                }
              },
              () {
                debugPrint('Sign Up successful for email: ${emailController.text.trim()}');
                if (context.mounted) {
                  CustomSnackbar.showSuccess(
                    context,
                    texts.signUpSuccess,
                  );
                  context.goNamed(AppRoute.login.name);
                }
              },
            );
      } else {
        debugPrint('Sign Up validation failed');
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
                      texts.signUpTitle,
                      style: AppTextStyles.colitez400Italic32(),
                    ),
                    SizedBox(height: 9.h),
                    Text(
                      texts.signUpSubtitle,
                      style: AppTextStyles.roboto300Light13(),
                    ),
                    SizedBox(height: 29.h),

                    AppLabelledTextField(
                      label: texts.fullNameLabel,
                      hintText: texts.fullNameHint,
                      controller: nameController,
                      focusNode: nameFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => emailFocus.requestFocus(),
                      validator: AppValidators.validateName,
                    ),
                    SizedBox(height: 16.h),

                    AppLabelledTextField(
                      label: texts.emailLabel,
                      hintText: texts.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      focusNode: emailFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                      validator: AppValidators.validateEmail,
                    ),
                    SizedBox(height: 16.h),

                    AppLabelledTextField(
                      label: texts.passwordLabel,
                      hintText: texts.passwordHint,
                      isPassword: true,
                      controller: passwordController,
                      focusNode: passwordFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          confirmPasswordFocus.requestFocus(),
                      validator: AppValidators.validatePassword,
                    ),
                    SizedBox(height: 16.h),

                    AppLabelledTextField(
                      label: texts.confirmPasswordLabel,
                      hintText: texts.confirmPasswordHint,
                      isPassword: true,
                      controller: confirmPasswordController,
                      focusNode: confirmPasswordFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onSignUpPressed(),
                      validator: (value) =>
                          AppValidators.validateConfirmPassword(
                            value,
                            passwordController.text,
                          ),
                    ),

                    SizedBox(height: 35.h),

                    PrimaryButton(
                      text: texts.signUpText,
                      onPressed: onSignUpPressed,
                      isLoading: isLoading,
                    ),

                    SizedBox(height: 32.h),
                    const OrDivider(),
                    SizedBox(height: 29.h),

                    SocialAuthButton(
                      text: 'Continue with Google',
                      iconPath: AppAssets.google,
                      onPressed: () {},
                    ),

                    const Spacer(),
                    SizedBox(height: 32.h),

                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // Navigate to Login
                          context.goNamed(AppRoute.login.name);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                          child: RichText(
                            text: TextSpan(
                              text: texts.alreadyHaveAccount,
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
                    SizedBox(height: 15.h), // Bottom padding
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
