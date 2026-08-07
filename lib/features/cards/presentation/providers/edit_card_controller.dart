import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../../features/payments/presentation/providers/payment_providers.dart';
import '../../../../features/payments/presentation/providers/payment_controller.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../providers/cards_provider.dart';
import '../../data/repositories/sms_repository_impl.dart';
import '../../domain/entities/delivery_method.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditCardState {
  final bool isLoading;
  const EditCardState({this.isLoading = false});
}

class EditCardController extends StateNotifier<EditCardState> {
  final Ref ref;

  EditCardController(this.ref) : super(const EditCardState());

  Future<void> handlePurchaseAndOrder({
    required BuildContext context,
    required String cardId,
    required String insideMessage,
    required String from,
    required String to,
    required int? draftId,
    required AppLocalizations texts,
    required PageController pageController,
    // Optional SMS delivery params
    String? recipientPhone,
    DeliveryMethod? deliveryMethod,
    String? coverImageUrl,
    String? frontMessage,
  }) async {
    // TEMPORARY: Bypass early field validation for testing.
    // To revert: uncomment the two blocks below.
    //
    // ── PRODUCTION: insideMessage check (commented out) ──────────────────
    // if (insideMessage.trim().isEmpty) {
    //   CustomSnackbar.showError(context, texts.pleaseEnterMessage);
    //   return;
    // }
    // ── PRODUCTION: from/to check (commented out) ─────────────────────────
    // if (from.trim().isEmpty || to.trim().isEmpty) {
    //   pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    //   return;
    // }


    state = const EditCardState(isLoading: true);

    // TEMPORARY: Bypass payment gate for testing the share/send flow.
    // To revert: delete the try-finally below and uncomment the
    // production block marked with PRODUCTION START/END.
    try {
      // ── BYPASS START ────────────────────────────────────────────────────
      await _placeOrderAndSend(
        context: context,
        cardId: cardId,
        insideMessage: insideMessage,
        from: from,
        draftId: draftId,
        texts: texts,
        recipientPhone: recipientPhone,
        deliveryMethod: deliveryMethod,
        coverImageUrl: coverImageUrl,
        frontMessage: frontMessage,
      );
      // ── BYPASS END ──────────────────────────────────────────────────────

      // ── PRODUCTION START (commented out) ────────────────────────────────
      // final customerInfo = ref.read(customerInfoStreamProvider).valueOrNull;
      // final hasActiveSubscription = customerInfo?.entitlements.active.containsKey('premium') ?? false;
      //
      // if (hasActiveSubscription) {
      //   await _placeOrderAndSend(
      //     context: context,
      //     cardId: cardId,
      //     insideMessage: insideMessage,
      //     from: from,
      //     draftId: draftId,
      //     texts: texts,
      //     recipientPhone: recipientPhone,
      //     deliveryMethod: deliveryMethod,
      //     coverImageUrl: coverImageUrl,
      //     frontMessage: frontMessage,
      //   );
      // } else {
      //   final offeringsAsync = ref.read(offeringsProvider);
      //   final availablePackages = offeringsAsync.valueOrNull?.current?.availablePackages ?? [];
      //   final singleCardPackage = availablePackages.firstWhereOrNull(
      //     (p) => p.storeProduct.identifier == 'rivon_single_card' || p.identifier == 'single_card' || p.identifier == 'single-card-purchase'
      //   );
      //
      //   if (singleCardPackage != null) {
      //     final success = await ref.read(paymentControllerProvider.notifier).purchase(context, singleCardPackage);
      //     if (success) {
      //       await _placeOrderAndSend(
      //         context: context,
      //         cardId: cardId,
      //         insideMessage: insideMessage,
      //         from: from,
      //         draftId: draftId,
      //         texts: texts,
      //         recipientPhone: recipientPhone,
      //         deliveryMethod: deliveryMethod,
      //         coverImageUrl: coverImageUrl,
      //         frontMessage: frontMessage,
      //       );
      //     }
      //   } else {
      //     CustomSnackbar.showError(context, texts.singleCardNotAvailable);
      //   }
      // }
      // ── PRODUCTION END ──────────────────────────────────────────────────
    } finally {
      if (mounted) {
        state = const EditCardState(isLoading: false);
      }
    }
  }

  Future<void> _placeOrderAndSend({
    required BuildContext context,
    required String cardId,
    required String insideMessage,
    required String from,
    required int? draftId,
    required AppLocalizations texts,
    String? recipientPhone,
    DeliveryMethod? deliveryMethod,
    String? coverImageUrl,
    String? frontMessage,
  }) async {
    final cardAsync = ref.read(cardDetailProvider(cardId));
    final card = cardAsync.valueOrNull;

    final order = OrderEntity(
      cardId: cardId,
      title: card?.title ?? texts.customizedCardFallback,
      message: insideMessage,
      addedAt: DateTime.now(),
    );
    ref.read(orderProvider.notifier).addOrder(order);

    if (draftId != null) {
      final db = ref.read(appDatabaseProvider);
      await db.draftsTable.deleteWhere((t) => t.id.equals(draftId));
    }

    if (recipientPhone != null && recipientPhone.isNotEmpty && deliveryMethod != null) {
      // Send via SMS/WhatsApp
      final user = Supabase.instance.client.auth.currentUser;
      final displayName = from.isNotEmpty
          ? from
          : (user?.userMetadata?['display_name'] as String? ?? 'A friend');

      final result = await ref.read(smsRepositoryProvider).sendCard(
        recipientPhone: recipientPhone,
        senderName: displayName,
        coverImageUrl: coverImageUrl ?? card?.coverImageUrl,
        frontMessage: frontMessage ?? card?.defaultFrontMessage,
        insideMessage: insideMessage,
        method: deliveryMethod,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          final userMessage = failure is SmsFailure
              ? 'Could not send the card: ${failure.message}'
              : texts.orderPlaced;
          if (context.mounted) CustomSnackbar.showError(context, userMessage);
          if (context.mounted) _navigateAfterOrder(context);
        },
        (_) {
          final channelName = deliveryMethod == DeliveryMethod.whatsApp ? 'WhatsApp' : 'SMS';
          if (context.mounted) {
            CustomSnackbar.showSuccess(context, 'Card sent via $channelName! 🎴');
            _navigateAfterOrder(context);
          }
        },
      );
    } else {
      if (!context.mounted) return;
      CustomSnackbar.showSuccess(context, texts.orderPlaced);
      _navigateAfterOrder(context);
    }
  }

  void _navigateAfterOrder(BuildContext context) {
    Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.goNamed(AppRoute.main.name);
          context.pushNamed(AppRoute.orderHistory.name);
        }
      },
    );
  }

  Future<void> saveDraft({
    required BuildContext context,
    required String cardId,
    required String coverText,
    required String insideMessage,
    required String draftName,
    required AppLocalizations texts,
  }) async {
    state = const EditCardState(isLoading: true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.into(db.draftsTable).insert(
        DraftsTableCompanion.insert(
          cardId: cardId,
          coverText: coverText,
          insideMessage: insideMessage,
          savedAt: DateTime.now(),
          draftName: drift.Value(draftName),
        ),
      );
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, texts.savedToMyDrafts);
        context.goNamed(AppRoute.myDrafts.name);
      }
    } finally {
      if (mounted) {
        state = const EditCardState(isLoading: false);
      }
    }
  }
}

final editCardControllerProvider = StateNotifierProvider<EditCardController, EditCardState>((ref) {
  return EditCardController(ref);
});
