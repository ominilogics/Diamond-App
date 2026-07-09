import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../../features/payments/presentation/providers/payment_providers.dart';
import '../../../../features/payments/presentation/providers/payment_controller.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../providers/cards_provider.dart';

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
  }) async {
    if (insideMessage.trim().isEmpty) {
      CustomSnackbar.showError(context, texts.pleaseEnterMessage);
      return;
    }
    if (from.trim().isEmpty || to.trim().isEmpty) {
      CustomSnackbar.showError(context, texts.pleaseFillRecipientFields);
      pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }

    state = const EditCardState(isLoading: true);

    try {
      final customerInfo = ref.read(customerInfoStreamProvider).valueOrNull;
      final hasActiveSubscription = customerInfo?.entitlements.active.containsKey('premium') ?? false;

      if (hasActiveSubscription) {
        await _placeOrder(context: context, cardId: cardId, insideMessage: insideMessage, draftId: draftId, texts: texts);
      } else {
        final offeringsAsync = ref.read(offeringsProvider);
        final availablePackages = offeringsAsync.valueOrNull?.current?.availablePackages ?? [];
        final singleCardPackage = availablePackages.firstWhereOrNull(
          (p) => p.storeProduct.identifier == 'rivon_single_card' || p.identifier == 'single_card' || p.identifier == 'single-card-purchase'
        );

        if (singleCardPackage != null) {
          final success = await ref.read(paymentControllerProvider.notifier).purchase(context, singleCardPackage);
          if (success) {
            await _placeOrder(context: context, cardId: cardId, insideMessage: insideMessage, draftId: draftId, texts: texts);
          }
        } else {
          CustomSnackbar.showError(context, texts.singleCardNotAvailable);
        }
      }
    } finally {
      if (mounted) {
        state = const EditCardState(isLoading: false);
      }
    }
  }

  Future<void> _placeOrder({
    required BuildContext context,
    required String cardId,
    required String insideMessage,
    required int? draftId,
    required AppLocalizations texts,
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

    if (!context.mounted) return;
    CustomSnackbar.showSuccess(context, texts.orderPlaced);

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
