import 'package:flutter/material.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/categories_section.dart';
import '../widgets/islamic_cards_section.dart';
import '../widgets/featured_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../../core/widgets/shimmers/card_shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final featuredCardsAsync = ref.watch(featuredCardsStreamProvider);
    // final searchQuery = ref.watch(searchQueryProvider);
    // final searchResultsAsync = ref.watch(searchResultsProvider);
    // final isSearching = searchQuery.trim().isNotEmpty;

    // Trigger background sync on screen load
    ref.watch(syncCardsProvider);

    return RefreshIndicator(
      color: AppColors.primaryButtonGradientStart,
      backgroundColor: Colors.white,
      onRefresh: () async {
        // Invalidate the provider to force a fresh network sync
        ref.invalidate(syncCardsProvider);
        // Wait for the sync to complete before stopping the spinner
        await ref.read(syncCardsProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),

                // 1. Top Bar
                AppBar1(
                  title: texts.welcomeBack,
                  textStyle: AppTextStyles.colitez400Italic32(),
                ),

                // 2. Welcome Section
                Padding(
                  padding: EdgeInsets.only(left: 30.w, right: 60),
                  child: Text(
                    texts.welcomeSubtitle,
                    style: AppTextStyles.roboto300Light13(),
                  ),
                ),
                SizedBox(height: 24.h),

                // 3. Search Bar
                // SearchBarWidget(
                //   onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                // ),
                // SizedBox(height: 32.h),

                // if (!isSearching) ...[
                // 4. Islamic Cards Section
                const IslamicCardsSection(),
                SizedBox(height: 32.h),

                // 5. Categories Section
                const CategoriesSection(),
                SizedBox(height: 32.h),

                  // 5. Featured Cards Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      texts.featuredCards,
                      style: AppTextStyles.colitez400Italic24(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                // ] else ...[
                //   // Search Results Header
                //   Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 24.w),
                //     child: Text(
                //       "Search Results", 
                //       style: AppTextStyles.colitez400Italic24(),
                //     ),
                //   ),
                //   SizedBox(height: 16.h),
                // ]
              ],
            ),
          ),

          // Featured Cards Grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            sliver: featuredCardsAsync.when(
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
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No featured cards available',
                        style: AppTextStyles.roboto300Light13(),
                      ),
                    ),
                  );
                }
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 171.w / 204.h,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                    },
                    childCount: cards.length,
                  ),
                );
              },
            ),
          ),
          
          SliverToBoxAdapter(
            child: SizedBox(height: 40.h), // Bottom padding
          ),
        ],
      ),
    );
  }
}
