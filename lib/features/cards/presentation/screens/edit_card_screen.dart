import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';

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
import 'package:drift/drift.dart' hide Column;
import '../providers/cards_provider.dart';
import '../../../../features/payments/presentation/providers/payment_providers.dart';
import '../../../../features/payments/presentation/providers/payment_controller.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import 'package:collection/collection.dart';
import '../widgets/edit_card_carousel.dart';
import '../providers/edit_card_controller.dart';

class EditCardScreen extends HookConsumerWidget {
  final String cardId;

  final String? coverImageUrl;
  final String? frontMessage;
  final String? initialMessage;
  final int? draftId;

  const EditCardScreen({
    super.key,
    required this.cardId,
    this.coverImageUrl,
    this.frontMessage,
    this.initialMessage,
    this.draftId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = useState(0);
    final pageController = usePageController(initialPage: 0);
    final isRecipientStep = useState(false);

    final coverTextController = useTextEditingController(
      text:
          frontMessage ??
          "Loving you has been one of life's greatest gifts. No matter where life takes us, my heart will always find its way back to you.",
    );
    final insideMessageController = useTextEditingController(
      text:
          initialMessage ??
          "Every day I spend with you reminds me how beautiful life can be when it's shared with someone who truly understands your heart. Your kindness, patience, and love have brought light into my life in ways I never imagined possible. Through every smile, every conversation, and every challenge we've faced together, you've shown me what unconditional love truly means.",
    );

    final fromController = useTextEditingController();
    final toController = useTextEditingController();
    final fromFocusNode = useFocusNode();
    final toFocusNode = useFocusNode();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final texts = AppLocalizations.of(context)!;
    final cardAsync = ref.watch(cardDetailProvider(cardId));
    final card = cardAsync.valueOrNull;

    final offeringsAsync = ref.watch(offeringsProvider);
    final paymentState = ref.watch(paymentControllerProvider);
    final customerInfo = ref.watch(customerInfoStreamProvider).valueOrNull;
    final hasActiveSubscription = customerInfo?.entitlements.active.containsKey('premium') ?? false;

    final editCardState = ref.watch(editCardControllerProvider);

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
                        AppBar2(
                          title: texts.customizeCard,
                          onBackPressed: showExitDialog,
                        ),
                      ],
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      // Carousel Container
                      EditCardCarousel(
                        pageController: pageController,
                        currentPage: currentPage.value,
                        onPageChanged: (index) {
                          currentPage.value = index;
                          if (index == 2 && !isRecipientStep.value) {
                            isRecipientStep.value = true;
                          } else if (index < 2 && isRecipientStep.value) {
                            isRecipientStep.value = false;
                          }
                        },
                        coverImageUrl: coverImageUrl,
                        coverTextController: coverTextController,
                        insideMessageController: insideMessageController,
                      ),
                      SizedBox(height: 24.h),

                      if (!isRecipientStep.value) ...[
                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              card?.title ?? '',
                              style: AppTextStyles.colitez400Italic24(),
                            ),
                            Text(
                              '\$ 5.99', // Keep price hardcoded or use card.price if it exists later
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
                          inputFormatters: [
                            PhysicalBoundsTextInputFormatter(
                              style: AppTextStyles.bizudMincho400Regular12(
                                color: Colors.white,
                              ),
                              maxWidth: 197.w, // 255.w - 29.w - 29.w
                              maxHeight: 81.h, // 358.h - 253.h - 24.h
                              isUpperCase: true,
                              textScaler: MediaQuery.textScalerOf(context),
                            ),
                          ],
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
                          inputFormatters: [
                            PhysicalBoundsTextInputFormatter(
                              style: AppTextStyles.bizudMincho400Regular12(
                                color: Colors.black,
                              ),
                              maxWidth: 215.w, // 255.w - 20.w - 20.w
                              maxHeight: 318.h, // 358.h - 20.h - 20.h
                              isUpperCase: true,
                              textScaler: MediaQuery.textScalerOf(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        // Buttons
                        PrimaryButton(
                          text: texts.continueText,
                          onPressed: () {
                            if (coverTextController.text.trim().isEmpty ||
                                insideMessageController.text.trim().isEmpty) {
                              CustomSnackbar.showError(
                                context,
                                texts.pleaseFillMessageFields,
                              );
                              return;
                            }
                            if (fromController.text.trim().isEmpty ||
                                toController.text.trim().isEmpty) {
                              CustomSnackbar.showError(
                                context,
                                texts.pleaseFillRecipientFields,
                              );
                              pageController.animateToPage(
                                2,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
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
                            final coverText = coverTextController.text.trim();
                            final insideText = insideMessageController.text
                                .trim();

                            if (coverText.isEmpty || insideText.isEmpty) {
                              CustomSnackbar.showError(
                                context,
                                texts.fieldsCannotBeEmpty,
                              );
                              return;
                            }

                            final draftNameController = TextEditingController();
                            final result = await showDialog<String>(
                              context: context,
                              builder: (dialogContext) => Dialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                insetPadding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                ),
                                child: Container(
                                  width: 310.w,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 32.h,
                                    horizontal: 8.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: const Color(0xFF000000),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        texts.saveDraft,
                                        style:
                                            AppTextStyles.colitez400Italic20(),
                                      ),
                                      SizedBox(height: 24.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                        ),
                                        child: AppTextField(
                                          controller: draftNameController,
                                          hintText: texts.enterDraftName,
                                          maxLength: 15,
                                        ),
                                      ),
                                      SizedBox(height: 32.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => Navigator.of(
                                                  dialogContext,
                                                ).pop(),
                                                child: Container(
                                                  height: 34.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    texts.cancel,
                                                    style:
                                                        AppTextStyles.roboto500Medium14(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 15.w),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  final name =
                                                      draftNameController.text
                                                          .trim();
                                                  if (name.isEmpty) {
                                                    CustomSnackbar.showError(
                                                      dialogContext,
                                                      texts.pleaseEnterName,
                                                    );
                                                    return;
                                                  }
                                                  if (name.length > 15) {
                                                    CustomSnackbar.showError(
                                                      dialogContext,
                                                      texts
                                                          .nameExceeds15Letters,
                                                    );
                                                    return;
                                                  }
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop(name);
                                                },
                                                child: Container(
                                                  height: 34.h,
                                                  decoration: BoxDecoration(
                                                    gradient: AppColors
                                                        .primaryButtonGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    texts.save,
                                                    style:
                                                        AppTextStyles.roboto500Medium14()
                                                            .copyWith(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                  ),
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
                              ref.read(editCardControllerProvider.notifier).saveDraft(
                                context: context,
                                cardId: cardId,
                                coverText: coverTextController.text,
                                insideMessage: insideMessageController.text,
                                draftName: result,
                                texts: texts,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(double.infinity, 44.h),
                            side: BorderSide(color: Colors.black, width: 0.5.w),
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
                                onFieldSubmitted: (_) =>
                                    toFocusNode.requestFocus(),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? texts.thisFieldIsRequired
                                    : null,
                              ),
                              SizedBox(height: 24.h),
                              AppTextField(
                                labelText: texts.toLabel,
                                hintText: texts.toHint,
                                controller: toController,
                                focusNode: toFocusNode,
                                textInputAction: TextInputAction.done,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? texts.thisFieldIsRequired
                                    : null,
                              ),
                              SizedBox(height: 32.h),
                              PrimaryButton(
                                text: texts.sendButton,
                                isLoading: editCardState.isLoading,
                                onPressed: editCardState.isLoading ? null : () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    ref.read(editCardControllerProvider.notifier).handlePurchaseAndOrder(
                                      context: context,
                                      cardId: cardId,
                                      insideMessage: insideMessageController.text,
                                      from: fromController.text,
                                      to: toController.text,
                                      draftId: draftId,
                                      texts: texts,
                                      pageController: pageController,
                                    );
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
            ],
          ),
        ),
      ),
    );
  }
}

class PhysicalBoundsTextInputFormatter extends TextInputFormatter {
  final TextStyle style;
  final double maxWidth;
  final double maxHeight;
  final bool isUpperCase;
  final TextScaler textScaler;

  PhysicalBoundsTextInputFormatter({
    required this.style,
    required this.maxWidth,
    required this.maxHeight,
    required this.textScaler,
    this.isUpperCase = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final span = TextSpan(
      text: isUpperCase ? newValue.text.toUpperCase() : newValue.text,
      style: style,
    );
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    );
    tp.layout(maxWidth: maxWidth);

    if (tp.height > maxHeight) {
      return oldValue; // Reject change if it physically overflows the card bounds
    }
    return newValue;
  }
}
