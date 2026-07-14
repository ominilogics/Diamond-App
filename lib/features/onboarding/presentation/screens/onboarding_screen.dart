import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/app_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../providers/onboarding_provider.dart';

class OnboardingData {
  final String image;
  final String title;
  final String desc;
  final String? tag;
  final bool isCentered;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.desc,
    this.tag,
    this.isCentered = false,
  });
}

const List<OnboardingData> _onboardingPages = [
  OnboardingData(
    image: AppAssets.onboarding1,
    title: 'Find the perfect card\nfor every moment.',
    desc:
        'From joyful celebrations to heartfelt messages, discover beautifully crafted cards for every occasion. Browse a thoughtfully curated collection and find the perfect way to express your feelings in just a few taps.',
  ),
  OnboardingData(
    image: AppAssets.onboarding2,
    title: 'Personalize it\nwith love.',
    desc:
        'Make every card uniquely yours by adding a heartfelt message and choosing a design that reflects your style. Create something meaningful that your loved ones will truly cherish.',
  ),
  OnboardingData(
    image: AppAssets.onboarding3,
    title: 'Make someone\nsmile today.',
    desc:
        'Share your personalized card instantly with friends and family, no matter where they are. Turn everyday moments into lasting memories with thoughtful words and beautiful designs.',
  ),
  OnboardingData(
    image: AppAssets.onboarding4,
    title: 'Make Every Moment\nMore Meaningful.',
    desc:
        'Send beautiful greeting cards with heartfelt messages to the people who matter most.',
    tag: 'Beautiful Cards for Every Occasion',
    isCentered: true,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  bool _isLoadingGuest = false;

  Future<void> _completeOnboarding(VoidCallback navigate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    AppRouter.hasSeenOnboarding = true;
    if (mounted) {
      navigate();
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(onboardingCurrentPageProvider),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(onboardingCurrentPageProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamically adjust top positions to prevent overflow on small devices
    final isSmallScreen = screenHeight < 700;

    // Calculate precise widths for custom animation
    final totalWidth = MediaQuery.of(context).size.width - 48.w;
    final hasBack = currentIndex > 0;

    // Back button should be 70% the size of the Next button
    final backRatio = 0.7 / 1.7;
    final nextRatio = 1.0 / 1.7;

    final backContainerWidth = hasBack
        ? ((totalWidth - 16.w) * backRatio) + 16.w
        : 0.0;
    final nextWidth = hasBack ? ((totalWidth - 16.w) * nextRatio) : totalWidth;

    return GradientScaffold(
      useSafeArea: false,
      body: Stack(
        children: [
          // Swipeable Image and Text Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              ref.read(onboardingCurrentPageProvider.notifier).state = index;
            },
            itemCount: _onboardingPages.length,
            itemBuilder: (context, index) {
              final isLastPage = index == _onboardingPages.length - 1;
              if (isLastPage) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 24.w,
                      // bottom: 6.h + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      children: [
                        Flexible(child: SizedBox(height: 20.h)),
                        Image.asset(
                          _onboardingPages[index].image,
                          width: 334.8.w,
                          height: 377.h,
                          fit: BoxFit.contain,
                        ),
                        Flexible(child: SizedBox(height: 66.h)),
                        Container(
                          width: double.infinity,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 0.5.w,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: const Color(0xFFFF5E60),
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  _onboardingPages[index].tag!,
                                  style: AppTextStyles.roboto300Light14(
                                    color: Colors.black,
                                  ).copyWith(letterSpacing: -0.03 * 14.sp),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          _onboardingPages[index].title,
                          style: AppTextStyles.colitez400Italic32(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            _onboardingPages[index].desc,
                            style: AppTextStyles.roboto300Light14().copyWith(
                              letterSpacing: -0.03 * 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(child: SizedBox(height: 38.h)),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: 'Explore Now',
                            isLoading: _isLoadingGuest,
                            onPressed: () async {
                              if (_isLoadingGuest) return;
                              setState(() => _isLoadingGuest = true);
                              try {
                                await Supabase.instance.client.auth
                                    .signInAnonymously();
                                if (context.mounted) {
                                  _completeOnboarding(() {
                                    context.replaceNamed(AppRoute.main.name);
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error: Anonymous sign-ins are disabled in Supabase.',
                                      ),
                                    ),
                                  );
                                  setState(() => _isLoadingGuest = false);
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: double.infinity,
                          child: SecondaryButton(
                            text: 'Log In',
                            onPressed: () {
                              _completeOnboarding(() {
                                context.replaceNamed(AppRoute.login.name);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final pageTextTop = isSmallScreen ? 0.55 : 0.65;
              final pageImageHeight = isSmallScreen ? 0.60 : 0.70;

              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: screenHeight * pageImageHeight,
                    child: Image.asset(
                      _onboardingPages[index].image,
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Positioned(
                    bottom: 150.h + MediaQuery.paddingOf(context).bottom,
                    left: 24.w,
                    right: 24.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _onboardingPages[index].title,
                          style: AppTextStyles.colitez400Italic32(),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          _onboardingPages[index].desc,
                          style: AppTextStyles.roboto300Light14(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Stationary Dots and Buttons Overlay
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 24.h + MediaQuery.paddingOf(context).bottom,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.2), // Subtle slide up
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: currentIndex < _onboardingPages.length - 1
                    ? Column(
                        key: const ValueKey('onboarding_nav'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _onboardingPages.length - 1,
                              (index) {
                                final isActive = currentIndex == index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(
                                    right: index == _onboardingPages.length - 2
                                        ? 0
                                        : 4.w,
                                  ),
                                  width: isActive ? 24.w : 8.w,
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryButtonGradient,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 31.h),

                          // Buttons
                          Row(
                            key: const ValueKey(
                              'nav_buttons_row',
                            ), // Constant key to prevent cross-fade
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: backContainerWidth,
                                alignment: Alignment
                                    .centerRight, // Slide in from the left
                                child: ClipRect(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width:
                                              (totalWidth - 16.w) * backRatio,
                                          child: SecondaryButton(
                                            text: 'back',
                                            onPressed: () {
                                              _pageController.previousPage(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: nextWidth,
                                child: PrimaryButton(
                                  text: 'Next',
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('last_page_buttons')),
              ),
            ),
          ),

          // Skip Button
          if (currentIndex < _onboardingPages.length - 1)
            Positioned(
              top: 24.h,
              right: 24.w,
              child: SafeArea(
                child: InkWell(
                  onTap: () {
                    _pageController.animateToPage(
                      _onboardingPages.length - 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.roboto400Regular16(
                        color: Colors.black87,
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
