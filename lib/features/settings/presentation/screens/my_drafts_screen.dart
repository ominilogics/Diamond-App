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

class MyDraftsScreen extends ConsumerWidget {
  const MyDraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final draftsStream = db.select(db.draftsTable).watch();
    final texts = AppLocalizations.of(context)!;

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            AppBar2(title: texts.myDrafts),
            SizedBox(height: 24.h),
            Expanded(
              child: StreamBuilder(
                stream: draftsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final drafts = snapshot.data ?? [];
                  if (drafts.isEmpty) {
                    return Center(
                      child: Text(
                        texts.noDraftsSavedYet,
                        style: AppTextStyles.roboto300Light13(),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: drafts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 171.w / 204.h,
                    ),
                    itemBuilder: (context, index) {
                      final draft = drafts[index];
                      return FeaturedCard(
                        cardId: draft.cardId,
                        title: draft.draftName ?? 'Draft',
                        cardColor: const Color(0xFFFFA7A7), // Default card color
                        onTap: () {
                          context.pushNamed(
                            AppRoute.editCard.name,
                            extra: {'cardId': draft.cardId},
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
