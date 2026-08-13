import 'package:daimond/core/routing/app_router.dart';
import 'package:daimond/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daimond/features/payments/presentation/providers/payment_controller.dart';
import 'package:daimond/features/payments/presentation/providers/payment_providers.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../features/main/presentation/screens/main_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/loading_progress_dialog.dart';
import '../../../../core/widgets/primary_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.session?.user ?? Supabase.instance.client.auth.currentUser;
    final bool isLoggedIn = user != null && !user.isAnonymous;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 12.h),
              AppBar1(title: texts.navSettings),
              SizedBox(height: 24.h),
            ],
          ),
        ),
        if (isLoggedIn)
          SliverToBoxAdapter(
            child: _buildLoggedInContent(context, texts, ref),
          )
        else
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildLoggedOutContent(context, texts),
          ),
      ],
    );
  }

  Widget _buildLoggedOutContent(BuildContext context, AppLocalizations texts) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            texts.loginPrompt,
            style: AppTextStyles.roboto400Regular20(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          PrimaryButton(
            text: texts.loginAction,
            onPressed: () {
              context.pushNamed(AppRoute.login.name);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInContent(
    BuildContext context,
    AppLocalizations texts,
    WidgetRef ref,
  ) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = Supabase.instance.client.auth.currentUser;
        final email = user?.email ?? texts.profileEmail;
        final rawName =
            user?.userMetadata?['custom_name'] as String? ??
            user?.userMetadata?['full_name'] as String? ??
            user?.userMetadata?['name'] as String? ??
            texts.profileName;
        final initial = rawName.isNotEmpty ? rawName[0].toUpperCase() : 'U';
        final avatarUrl =
            user?.userMetadata?['avatar_url'] as String? ??
            user?.userMetadata?['picture'] as String?;

        return Column(
          children: [
              // Header Profile Container
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: GestureDetector(
                  onTap: () => context.pushNamed(AppRoute.editProfile.name),
                  child: Container(
                    width: double.infinity,
                    height: 93.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFF000000),
                        width: 0.5.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20.w),
                        // Avatar
                        Container(
                          width: 57.w,
                          height: 57.w,
                          decoration: BoxDecoration(
                            color: AppColors.card2, // The purple color
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF000000),
                              width: 0.5.w,
                            ),
                          ),
                          child: avatarUrl != null && avatarUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    avatarUrl,
                                    width: 57.w,
                                    height: 57.w,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                          child: Text(
                                            initial,
                                            style:
                                                AppTextStyles.roboto400Regular20(
                                                  color: const Color(
                                                    0xFF000000,
                                                  ),
                                                  fontSize: 24.sp,
                                                ),
                                          ),
                                        ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initial,
                                    style: AppTextStyles.roboto400Regular20(
                                      color: const Color(0xFF000000),
                                      fontSize: 24.sp,
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rawName,
                                style: AppTextStyles.roboto400Regular18(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                email,
                                style: AppTextStyles.roboto300Light12(
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SvgPicture.asset(
                          AppAssets.forwardArrow,
                          width: 8.w,
                          height: 14.h,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 20.w),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Preferences Container
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF000000),
                      width: 0.5.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreferenceItem(
                        texts.subscriptions,
                        onTap: () =>
                            context.pushNamed(AppRoute.subscription.name),
                      ),
                      _buildDivider(),
                      _buildPreferenceItem(
                        texts.orderHistory,
                        onTap: () =>
                            context.pushNamed(AppRoute.orderHistory.name),
                      ),
                      _buildDivider(),
                      _buildPreferenceItem(
                        texts.myDrafts,
                        onTap: () => context.pushNamed(AppRoute.myDrafts.name),
                      ),
                      _buildDivider(),
                      _buildPreferenceItem(
                        texts.notificationsTitle,
                        onTap: () => context.pushNamed(
                          AppRoute.notificationSettings.name,
                        ),
                      ),
                      // _buildDivider(),
                      // _buildPreferenceItem(
                      //   texts.language,
                      //   onTap: () {
                      //     // Navigate to Language settings or show bottom sheet
                      //   },
                      // ),
                      _buildDivider(),
                      _buildPreferenceItem(
                        texts.privacyPolicy,
                        onTap: () =>
                            context.pushNamed(AppRoute.privacyPolicy.name),
                      ),
                      _buildDivider(),
                      _buildPreferenceItem(
                        texts.termsAndConditions,
                        onTap: () => context
                            .pushNamed(AppRoute.termsAndConditions.name),
                      ),
                      _buildDivider(),
                      _buildPreferenceItem(
                        texts.logout,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => ConfirmationDialog(
                              title: texts.logoutConfirmation,
                              message: texts.logoutMessage,
                              confirmText: texts.yes,
                              cancelText: texts.no,
                              onConfirm: () async {
                                Navigator.of(dialogContext).pop();

                                BuildContext? loaderContext;

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (c) {
                                    loaderContext = c;
                                    return LoadingProgressDialog(
                                      text: 'Logging out...',
                                    );
                                  },
                                );

                                void dismissLoader() {
                                  if (loaderContext != null && loaderContext!.mounted) {
                                    Navigator.of(loaderContext!).pop();
                                    loaderContext = null;
                                  } else if (AppRouter.rootNavigatorKey.currentState?.canPop() == true) {
                                    AppRouter.rootNavigatorKey.currentState?.pop();
                                  }
                                }

                                await ref.read(authProvider.notifier).signOut();

                                dismissLoader();
                                ref.read(bottomNavIndexProvider.notifier).state = 0;

                                if (context.mounted) {
                                  CustomSnackbar.showSuccess(
                                    context,
                                    texts.logoutSuccess,
                                  );
                                }
                                AppRouter.router.goNamed(AppRoute.login.name);
                              },
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildPreferenceItem(
                        texts.deleteAccount,
                        isLast: true,
                        isGradient: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => ConfirmationDialog(
                              title: texts.deleteAccountTitle,
                              message: texts.deleteAccountMessage,
                              confirmText: texts.yes,
                              cancelText: texts.no,
                              onConfirm: () async {
                                Navigator.of(dialogContext).pop();

                                final deletionStatusNotifier =
                                    ValueNotifier<String>('Deleting account data...');

                                BuildContext? loaderContext;

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (c) {
                                    loaderContext = c;
                                    return LoadingProgressDialog.dynamic(
                                      statusNotifier: deletionStatusNotifier,
                                    );
                                  },
                                );

                                void dismissLoader() {
                                  if (loaderContext != null && loaderContext!.mounted) {
                                    Navigator.of(loaderContext!).pop();
                                    loaderContext = null;
                                  } else if (AppRouter.rootNavigatorKey.currentState?.canPop() == true) {
                                    AppRouter.rootNavigatorKey.currentState?.pop();
                                  }
                                }

                                await ref
                                    .read(authProvider.notifier)
                                    .deleteAccount(
                                  (errorMessage) {
                                    dismissLoader();
                                    if (context.mounted) {
                                      CustomSnackbar.showError(
                                        context,
                                        errorMessage,
                                      );
                                    }
                                  },
                                  () {
                                    dismissLoader();
                                    ref
                                        .read(bottomNavIndexProvider.notifier)
                                        .state = 0;
                                    if (context.mounted) {
                                      CustomSnackbar.showSuccess(
                                        context,
                                        'Your account and associated data have been permanently deleted.',
                                      );
                                    }
                                    AppRouter.router.goNamed(
                                      AppRoute.login.name,
                                    );
                                  },
                                  onProgress: (stepText) {
                                    deletionStatusNotifier.value = stepText;
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
        );
      },
    );
  }

  Widget _buildPreferenceItem(
    String title, {
    bool isLast = false,
    bool isGradient = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isGradient
                ? ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryButtonGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      title,
                      style: AppTextStyles.roboto400Regular16(),
                    ),
                  )
                : Text(title, style: AppTextStyles.roboto400Regular16()),
            SvgPicture.asset(
              AppAssets.forwardArrow,
              width: 8.w,
              height: 14.h,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 0.5.h,
        color: const Color(0xFFA8A8A8),
      ),
    );
  }
}
