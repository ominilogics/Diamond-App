import 'package:flutter/material.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/categories_section.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/featured_card.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../../core/widgets/shimmers/card_shimmer.dart';
import '../../../../core/utils/app_helpers.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final featuredCardsAsync = ref.watch(featuredCardsStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final isSearching = searchQuery.trim().isNotEmpty;

    final searchController = useTextEditingController(
      text: ref.read(searchQueryProvider),
    );

    // Trigger background sync on screen load
    ref.watch(syncCardsProvider);

    return GestureDetector(
      onTap: () => AppHelpers.dismissKeyboard(),
      child: RefreshIndicator(
        color: AppColors.primaryButtonGradientStart,
        backgroundColor: Colors.white,
        onRefresh: () async {
          // Invalidate the provider to force a fresh network sync
          ref.invalidate(syncCardsProvider);
          // Wait for the sync to complete before stopping the spinner
          await ref.read(syncCardsProvider.future);
        },
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  AppBar1(
                    title: texts.welcomeBack,
                    textStyle: AppTextStyles.colitez400Italic32(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.w, right: 60),
                    child: Text(
                      texts.welcomeSubtitle,
                      style: AppTextStyles.roboto300Light13(),
                    ),
                  ),
                ],
              ),
            ),
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final isScrolled = constraints.scrollOffset > 0;
                return SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: isScrolled
                      ? AppColors.gradientStart
                      : Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 3.0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 76.h,
                  titleSpacing: 0,
                  title: Column(
                    children: [
                      SizedBox(height: 24.h),
                      SearchBarWidget(
                        controller: searchController,
                        onChanged: (val) =>
                            ref.read(searchQueryProvider.notifier).state = val,
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  if (!isSearching) ...[
                    // 1. Home Banner Carousel
                    const HomeBannerCarousel(),
                    SizedBox(height: 20.h),

                    // 2. Categories Section
                    const CategoriesSection(),
                    SizedBox(height: 32.h),

                    // 3. Featured Cards Section Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        texts.featuredCards,
                        style: AppTextStyles.colitez400Italic24(),
                      ),
                    ),
                    SizedBox(height: 16.h),



                  ] else ...[
                    // Search Results Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        "Search Results",
                        style: AppTextStyles.colitez400Italic24(),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),

            // Featured Cards Grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: (isSearching ? searchResultsAsync : featuredCardsAsync)
                  .when(
                    loading: () => SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14.w,
                        mainAxisSpacing: 14.h,
                        childAspectRatio: 171.w / 204.h,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const CardShimmer(),
                        childCount: 4,
                      ),
                    ),
                    error: (error, stack) => const SliverToBoxAdapter(
                      child: Center(child: Text('Error loading cards')),
                    ),
                    data: (cards) {
                      if (cards.isEmpty) {
                        if (isSearching) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100.h),
                              child: Center(
                                child: Text(
                                  'No search results found',
                                  style: AppTextStyles.roboto300Light13(),
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Instead of showing empty text, display shimmer to account for initial sync
                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14.w,
                              mainAxisSpacing: 14.h,
                              childAspectRatio: 171.w / 204.h,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const CardShimmer(),
                              childCount: 4,
                            ),
                          );
                        }
                      }
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14.w,
                          mainAxisSpacing: 14.h,
                          childAspectRatio: 171.w / 204.h,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final card = cards[index];
                          return FeaturedCard(
                            cardId: card.id,
                            title: card.title,
                            coverImageUrl: card.coverImageUrl,
                            frontMessage: card.defaultFrontMessage,
                            insideMessage: card.defaultInsideMessage,
                            cardColor: card.colorValue != null
                                ? Color(card.colorValue!)
                                : AppColors.card1,
                          );
                        }, childCount: cards.length),
                      );
                    },
                  ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: 40.h), // Bottom padding
            ),
          ],
        ),
      ),
    );
  }
}
