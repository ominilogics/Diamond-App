import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/app_bar2.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:daimond/l10n/app_localizations.dart';
import '../widgets/custom_card_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'package:drift/drift.dart' as drift;

class EditCardScreen extends HookConsumerWidget {
  final String cardId;

  const EditCardScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = useState(0);
    final pageController = usePageController(initialPage: 0);
    final isRecipientStep = useState(false);

    final coverTextController = useTextEditingController(
      text:
          "Loving you has been one of life's greatest gifts. No matter where life takes us, my heart will always find its way back to you.",
    );
    final insideMessageController = useTextEditingController(
      text:
          "Every day I spend with you reminds me how beautiful life can be when it's shared with someone who truly understands your heart. Your kindness, patience, and love have brought light into my life in ways I never imagined possible. Through every smile, every conversation, and every challenge we've faced together, you've shown me what unconditional love truly means.",
    );

    final fromController = useTextEditingController();
    final toController = useTextEditingController();
    final fromFocusNode = useFocusNode();
    final toFocusNode = useFocusNode();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    final texts = AppLocalizations.of(context)!;

    void showExitDialog() {
      showDialog(
        context: context,
        builder: (dialogContext) => ConfirmationDialog(
          title: texts.discardChanges,
          message: texts.discardChangesDesc,
          confirmText: texts.discard,
          cancelText: texts.keepEditing,
          onConfirm: () {
            Navigator.pop(dialogContext); // Close dialog
            context.pop(); // Go back
          },
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showExitDialog();
      },
      child: GradientScaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 12.h),
              AppBar2(title: texts.customizeCard, onBackPressed: showExitDialog),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carousel Container
                        Container(
                          width: double.infinity,
                          height: 453.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: const Color(0xFF000000),
                              width: 0.5.w,
                            ),
                          ),
                          child: PageView(
                            controller: pageController,
                            onPageChanged: (index) {
                              currentPage.value = index;
                              if (index == 2 && !isRecipientStep.value) {
                                isRecipientStep.value = true;
                              } else if (index < 2 && isRecipientStep.value) {
                                isRecipientStep.value = false;
                              }
                            },
                            children: [
                              // Front Cover
                              Center(
                                child: SvgPicture.asset(
                                  AppAssets.gatta,
                                  fit: BoxFit.contain,
                                  width: 253.w,
                                  height: 358.h,
                                ),
                              ),
                              // Inside Card
                              Center(
                                child: SvgPicture.asset(
                                  AppAssets.gatta,
                                  fit: BoxFit.contain,
                                  width: 253.w,
                                  height: 358.h,
                                ),
                              ),
                              // Envelope / Third Step
                              Center(
                                child: SvgPicture.asset(
                                  AppAssets.gatta,
                                  fit: BoxFit.contain,
                                  width: 253.w,
                                  height: 358.h,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Carousel Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final isActive = currentPage.value == index;
                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isActive ? 1.0 : 0.3,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                width: isActive ? 24.w : 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryButtonGradient,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 24.h),

                        if (!isRecipientStep.value) ...[
                          // Title and Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'HBD 01',
                                style: AppTextStyles.colitez400Italic24(),
                              ),
                              Text(
                                '\$ 5.99',
                                style: AppTextStyles.colitez400Italic24(),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          // Edit Cover Text
                          Text(
                            texts.editCoverText,
                            style: AppTextStyles.colitez400Italic16(),
                          ),
                          SizedBox(height: 8.h),
                          CustomCardTextField(
                            controller: coverTextController,
                            maxLines: 4,
                          ),
                          SizedBox(height: 24.h),

                          // Edit Inside Message
                          Text(
                            texts.editInsideMessage,
                            style: AppTextStyles.colitez400Italic16(),
                          ),
                          SizedBox(height: 8.h),
                          CustomCardTextField(
                            controller: insideMessageController,
                            maxLines: 5,
                          ),
                          SizedBox(height: 32.h),

                          // Buttons
                          PrimaryButton(
                            text: texts.continueText,
                            onPressed: () {
                              if (coverTextController.text.trim().isEmpty || insideMessageController.text.trim().isEmpty) {
                                CustomSnackbar.showError(context, 'Please fill out all message fields.');
                                return;
                              }
                              if (fromController.text.trim().isEmpty || toController.text.trim().isEmpty) {
                                CustomSnackbar.showError(context, 'Please fill out all recipient fields.');
                                pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                return;
                              }
                              // Navigate back to the Card Detail Screen with updated data
                              context.pop({
                                'coverText': coverTextController.text,
                                'insideMessage': insideMessageController.text,
                              });
                            },
                          ),
                          SizedBox(height: 16.h),
                          OutlinedButton(
                            onPressed: () async {
                              final draftNameController = TextEditingController();
                              final result = await showDialog<String>(
                                context: context,
                                builder: (dialogContext) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
                                  child: Container(
                                    width: 310.w,
                                    padding: EdgeInsets.symmetric(vertical: 24.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(color: const Color(0xFF000000), width: 0.5),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Save Draft',
                                          style: AppTextStyles.colitez400Italic20(),
                                        ),
                                        SizedBox(height: 16.h),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                                          child: AppTextField(
                                            controller: draftNameController,
                                            hintText: 'Enter draft name...',
                                            maxLength: 15,
                                          ),
                                        ),
                                        SizedBox(height: 24.h),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => Navigator.of(dialogContext).pop(),
                                                  child: Container(
                                                    height: 34.h,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(20.r),
                                                      border: Border.all(color: Colors.black, width: 0.5),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text('Cancel', style: AppTextStyles.roboto500Medium14()),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15.w),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    final name = draftNameController.text.trim();
                                                    if (name.isEmpty) {
                                                      CustomSnackbar.showError(dialogContext, 'Please enter a name.');
                                                      return;
                                                    }
                                                    if (name.length > 15) {
                                                      CustomSnackbar.showError(dialogContext, 'Name cannot exceed 15 letters.');
                                                      return;
                                                    }
                                                    Navigator.of(dialogContext).pop(name);
                                                  },
                                                  child: Container(
                                                    height: 34.h,
                                                    decoration: BoxDecoration(
                                                      gradient: AppColors.primaryButtonGradient,
                                                      borderRadius: BorderRadius.circular(20.r),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text('Save', style: AppTextStyles.roboto500Medium14().copyWith(color: Colors.white)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              if (result != null) {
                                final db = ref.read(appDatabaseProvider);
                                await db
                                    .into(db.draftsTable)
                                    .insert(
                                      DraftsTableCompanion.insert(
                                        cardId: cardId,
                                        coverText: coverTextController.text,
                                        insideMessage: insideMessageController.text,
                                        savedAt: DateTime.now(),
                                        draftName: drift.Value(result),
                                      ),
                                    );
                                if (context.mounted) {
                                  CustomSnackbar.showSuccess(context, texts.savedToMyDrafts);
                                  context.goNamed(AppRoute.myDrafts.name);
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(double.infinity, 44.h),
                              side: BorderSide(
                                color: Colors.black,
                                width: 0.5.w,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            child: Text(
                              texts.saveDraft,
                              style: AppTextStyles.colitez400Italic22(),
                            ),
                          ),
                        ] else ...[
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    texts.addRecipient,
                                    style: AppTextStyles.colitez400Italic24(),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                AppTextField(
                                  labelText: texts.fromLabel,
                                  hintText: texts.fromHint,
                                  controller: fromController,
                                  focusNode: fromFocusNode,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => toFocusNode.requestFocus(),
                                  validator: (value) => value == null || value.trim().isEmpty ? 'This field is required' : null,
                                ),
                                SizedBox(height: 24.h),
                                AppTextField(
                                  labelText: texts.toLabel,
                                  hintText: texts.toHint,
                                  controller: toController,
                                  focusNode: toFocusNode,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) => value == null || value.trim().isEmpty ? 'This field is required' : null,
                                ),
                                SizedBox(height: 32.h),
                                PrimaryButton(
                                  text: texts.sendButton,
                                  onPressed: () {
                                    if (formKey.currentState?.validate() ?? false) {
                                      // Handle send logic here
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
