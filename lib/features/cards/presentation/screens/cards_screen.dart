import 'package:flutter/material.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../home/presentation/widgets/featured_card.dart';
import '../../../home/presentation/widgets/search_bar_widget.dart';
import '../providers/cards_provider.dart';
import '../../../../core/widgets/shimmers/card_shimmer.dart';
import '../../../../core/widgets/shimmers/category_shimmer.dart';
import '../../../../core/utils/category_localization.dart';

class CardsScreen extends HookConsumerWidget {
  final String? title;
  final bool showBackButton;
  final String? initialCategoryId;

  const CardsScreen({
    super.key,
    this.title,
    this.showBackButton = false,
    this.initialCategoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;
    final screenTitle = title?.replaceAll('\n', ' ') ?? texts.navCards;

    final selectedCategoryId = useState<String?>(initialCategoryId);
    final selectedItemKey = useMemoized(() => GlobalKey());

    // Create the controller here so it survives SliverAppBar scrolling
    final searchController = useTextEditingController(
      text: ref.read(searchQueryProvider),
    );

    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final isSearching = searchQuery.trim().isNotEmpty;

    final categoriesAsync = ref.watch(categoriesStreamProvider);

    useEffect(() {
      if (categoriesAsync.value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (selectedItemKey.currentContext != null) {
            Scrollable.ensureVisible(
              selectedItemKey.currentContext!,
              alignment: 0.5,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
      return null;
    }, [categoriesAsync.value, selectedCategoryId.value]);

    final cardsAsync = selectedCategoryId.value == null
        ? ref.watch(allCardsStreamProvider)
        : ref.watch(categoryCardsStreamProvider(selectedCategoryId.value!));

    final displayAsync = isSearching ? searchResultsAsync : cardsAsync;

    Widget content = CustomScrollView(
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final isScrolled = constraints.scrollOffset > 0;
            return SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: isScrolled
                  ? AppColors.gradientStart
                  : Colors
                        .transparent, // Solid background so cards don't bleed through
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 3.0,
              automaticallyImplyLeading: false,
              toolbarHeight: 60.h,
              titleSpacing: 0,
              title: Column(
                children: [
                  SizedBox(height: 12.h),
                  showBackButton
                      ? AppBar2(title: screenTitle)
                      : AppBar1(title: screenTitle),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                  78.h,
                ), // Approximate height of chips + padding
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    /*
                    SearchBarWidget(
                      controller: searchController,
                      onChanged: (val) =>
                          ref.read(searchQueryProvider.notifier).state = val,
                    ),
                    SizedBox(height: 24.h),
                    */
                    SizedBox(
                      height: 30.h,
                      child: categoriesAsync.when(
                        loading: () => ListView.separated(
                          key: const PageStorageKey('categories_loading_list'),
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 8.w),
                          itemBuilder: (context, index) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 76.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                          ),
                        ),
                        error: (error, stack) => const Center(
                          child: Text('Error loading categories'),
                        ),
                        data: (categories) {
                          final allCategories = [null, ...categories];
                          return ListView.separated(
                            key: const PageStorageKey('categories_list'),
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: allCategories.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              final cat = allCategories[index];
                              final isSelected =
                                  selectedCategoryId.value == (cat?.id);
                              final itemKey = isSelected ? selectedItemKey : null;
                              final name = cat == null
                                  ? texts.all
                                  : cat.name.localized(texts);

                              return GestureDetector(
                                key: itemKey,
                                onTap: () {
                                  selectedCategoryId.value = cat?.id;
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 76.w),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  height: 30.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? null
                                        : Colors.transparent,
                                    gradient: isSelected
                                        ? AppColors.primaryButtonGradient
                                        : null,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: const Color(0xFF000000),
                                            width: 0.5.w,
                                          ),
                                  ),
                                  child: Text(
                                    name,
                                    style: AppTextStyles.roboto400Regular14(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          sliver: displayAsync.when(
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
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: Text(
                        isSearching
                            ? 'No cards found for "$searchQuery"'
                            : 'No cards available in this category',
                        style: AppTextStyles.roboto300Light13(),
                      ),
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
        SliverToBoxAdapter(child: SizedBox(height: 40.h)),
      ],
    );

    if (showBackButton) {
      return GradientScaffold(body: SafeArea(child: content));
    }

    return content;
  }
}
