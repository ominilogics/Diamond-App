import 'package:daimond/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_bar1.dart';
import '../../../home/presentation/widgets/featured_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/primary_button.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = AppLocalizations.of(context)!;

    final favoritesState = ref.watch(favoritesProvider);
    final favorites = favoritesState.valueOrNull ?? [];

    final allCardsState = ref.watch(allCardsStreamProvider);
    final allCards = allCardsState.valueOrNull ?? [];

    final authState = ref.watch(authStateProvider);
    final user = authState.value?.session?.user ?? Supabase.instance.client.auth.currentUser;
    final bool isLoggedIn = user != null && !user.isAnonymous;

    return RefreshIndicator(
      color: AppColors.primaryButtonGradientStart,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await ref.read(favoritesProvider.notifier).syncAndRefresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 12.h),
                AppBar1(title: texts.favoritesTitle),
                SizedBox(height: 24.h),
              ],
            ),
          ),
          if (!isLoggedIn)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
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
              ),
            )
          else if (favorites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppAssets.favouritesEmpty),
                  SizedBox(height: 24.h),
                  Text(
                    texts.noCardsHere,
                    style: AppTextStyles.colitez400Italic32(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                  childAspectRatio: 171.w / 204.h,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final favorite = favorites[index];
                    final card = allCards.firstWhereOrNull(
                      (c) => c.id == favorite.cardId,
                    );
                    return FeaturedCard(
                      cardId: favorite.cardId,
                      title: favorite.title,
                      cardColor: Color(favorite.colorValue),
                      coverImageUrl: card?.coverImageUrl,
                      frontMessage: card?.defaultFrontMessage,
                      insideMessage: card?.defaultInsideMessage,
                    );
                  },
                  childCount: favorites.length,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: 40.h),
          ),
        ],
      ),
    );
  }
}
