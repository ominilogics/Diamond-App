import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../home/presentation/widgets/featured_card.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import 'package:collection/collection.dart';

class MyDraftsScreen extends ConsumerWidget {
  const MyDraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final draftsStream = db.select(db.draftsTable).watch();
    final texts = AppLocalizations.of(context)!;

    final allCardsState = ref.watch(allCardsStreamProvider);
    final allCards = allCardsState.valueOrNull ?? [];

    return GradientScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final isScrolled = constraints.scrollOffset > 0;
                return SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: isScrolled
                      ? const Color(0xFFE7FFEC)
                      : Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 3.0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 60.h,
                  titleSpacing: 0,
                  title: Column(
                    children: [
                      SizedBox(height: 12.h),
                      AppBar2(title: texts.myDrafts),
                    ],
                  ),
                );
              },
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            StreamBuilder(
              stream: draftsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final drafts = snapshot.data ?? [];
                if (drafts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        texts.noDraftsSavedYet,
                        style: AppTextStyles.roboto300Light13(),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 171.w / 204.h,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final draft = drafts[index];
                      final card = allCards.firstWhereOrNull(
                        (c) => c.id == draft.cardId,
                      );

                      return FeaturedCard(
                        cardId: draft.cardId,
                        title: draft.draftName ?? 'Draft',
                        cardColor: const Color(
                          0xFFFFA7A7,
                        ), // Default card color
                        coverImageUrl: card?.coverImageUrl,
                        frontMessage: card?.defaultFrontMessage,
                        insideMessage: card?.defaultInsideMessage,
                        onDelete: () async {
                          await db.draftsTable.deleteWhere((t) => t.id.equals(draft.id));
                        },
                        onTap: () {
                          context.pushNamed(
                            AppRoute.editCard.name,
                            extra: {
                              'cardId': draft.cardId,
                              'coverImageUrl': card?.coverImageUrl,
                              'frontMessage': draft.coverText,
                              'initialMessage': draft.insideMessage,
                              'draftId': draft.id,
                            },
                          );
                        },
                      );
                    }, childCount: drafts.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
