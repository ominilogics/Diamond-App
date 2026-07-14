import 'package:daimond/core/routing/app_router.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final texts = AppLocalizations.of(context)!;

    final isLoading = ref.watch(authProvider);

    void onLoginPressed() {
      if (formKey.currentState!.validate()) {
        debugPrint(
          'Login process started for email: ${emailController.text.trim()}',
        );
        ref
            .read(authProvider.notifier)
            .signIn(
              emailController.text.trim(),
              passwordController.text.trim(),
              (errorMessage) {
                debugPrint('Login failed: $errorMessage');
                if (context.mounted) {
                  CustomSnackbar.showError(context, errorMessage);
                }
              },
              () {
                debugPrint(
                  'Login successful for email: ${emailController.text.trim()}',
                );

                if (context.mounted) {
                  CustomSnackbar.showSuccess(context, texts.loginSuccess);
                  if (kIsWeb) {
                    context.goNamed(AppRoute.adminDashboard.name);
                  } else {
                    context.goNamed(AppRoute.main.name);
                  }
                }

                // Request Notification Permission based on Android versions in the background
                Future.microtask(() async {
                  if (kIsWeb) return; // Skip permissions on web
                  if (Platform.isAndroid) {
                    final androidInfo = await DeviceInfoPlugin().androidInfo;
                    final sdkInt = androidInfo.version.sdkInt;

                    if (sdkInt < 29) {
                      // Android below 10
                      await Permission.notification.request();
                    } else if (sdkInt >= 29 && sdkInt < 33) {
                      // Android 10 to 12
                      await Permission.notification.request();
                    } else {
                      // Android 13+ (12+)
                      await Permission.notification.request();
                    }
                  } else {
                    await Permission.notification.request();
                  }
                });
              },
            );
      } else {
        debugPrint('Login validation failed');
      }
    }

    return GradientScaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: kIsWeb
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 36.h),
                        Text(
                          texts.loginTitle,
                          style: AppTextStyles.colitez400Italic32(),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          texts.loginSubtitle,
                          style: AppTextStyles.roboto300Light13(),
                        ),
                        SizedBox(height: 29.h),

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
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => onLoginPressed(),
                          validator: AppValidators.validateLoginPassword,
                        ),
                        // The top padding is handled by the GestureDetector's padding
                        if (!kIsWeb)
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                context.goNamed(AppRoute.forgotPassword.name);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 8.h,
                                  bottom: 8.h,
                                  left: 16.w,
                                ),
                                child: Text(
                                  texts.forgotPasswordTitle,
                                  style: AppTextStyles.roboto300Light13(),
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(height: 24.h),

                        SizedBox(height: 24.h),

                        PrimaryButton(
                          text: texts.logIn,
                          onPressed: onLoginPressed,
                          isLoading: isLoading,
                        ),

                        if (!kIsWeb) ...[
                          SizedBox(height: 32.h),
                          const OrDivider(),
                          SizedBox(height: 29.h),

                          SocialAuthButton(
                            text: 'Continue with Google',
                            iconPath: AppAssets.google,
                            onPressed: () {
                              ref
                                  .read(authProvider.notifier)
                                  .signInWithGoogle(
                                    (errorMessage) {
                                      if (context.mounted) {
                                        CustomSnackbar.showError(
                                          context,
                                          errorMessage,
                                        );
                                      }
                                    },
                                    () {
                                      if (context.mounted) {
                                        CustomSnackbar.showSuccess(
                                          context,
                                          texts.loginSuccess,
                                        );
                                        context.goNamed(AppRoute.main.name);
                                      }

                                      // Request Notification Permission based on Android versions in the background
                                      Future.microtask(() async {
                                        if (Platform.isAndroid) {
                                          final androidInfo =
                                              await DeviceInfoPlugin()
                                                  .androidInfo;
                                          final sdkInt =
                                              androidInfo.version.sdkInt;

                                          if (sdkInt < 29) {
                                            await Permission.notification
                                                .request();
                                          } else if (sdkInt >= 29 &&
                                              sdkInt < 33) {
                                            await Permission.notification
                                                .request();
                                          } else {
                                            await Permission.notification
                                                .request();
                                          }
                                        } else {
                                          await Permission.notification
                                              .request();
                                        }
                                      });
                                    },
                                  );
                            },
                          ),

                          const Spacer(),
                          SizedBox(height: 32.h),

                          Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                // Navigate to Sign Up
                                context.goNamed(AppRoute.signup.name);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.h,
                                  horizontal: 16.w,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: texts.noAccount,
                                    style: AppTextStyles.roboto300Light14(),
                                    children: [
                                      TextSpan(
                                        text: texts.signUpText,
                                        style:
                                            AppTextStyles.roboto400Regular14(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h), // Bottom padding
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
