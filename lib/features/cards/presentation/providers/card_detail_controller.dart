import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../../features/payments/presentation/providers/payment_providers.dart';
import '../../../../features/payments/presentation/providers/payment_controller.dart';

class CardDetailState {
  final bool isLoading;
  const CardDetailState({this.isLoading = false});
}

class CardDetailController extends StateNotifier<CardDetailState> {
  final Ref ref;

  CardDetailController(this.ref) : super(const CardDetailState());

  Future<void> handlePurchaseAndOrder({
    required BuildContext context,
    required String cardId,
    required String title,
    required String message,
    required String from,
    required String to,
    required AppLocalizations texts,
    required PageController pageController,
  }) async {
    if (message.trim().isEmpty) {
      CustomSnackbar.showError(context, texts.pleaseEnterMessage);
      return;
    }
    if (from.trim().isEmpty || to.trim().isEmpty) {
      pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }


    state = const CardDetailState(isLoading: true);

    try {
      final customerInfo = ref.read(customerInfoStreamProvider).valueOrNull;
      final hasActiveSubscription = customerInfo?.entitlements.active.containsKey('premium') ?? false;

      if (hasActiveSubscription) {
        _placeOrder(context: context, cardId: cardId, title: title, message: message, texts: texts);
      } else {
        final offeringsAsync = ref.read(offeringsProvider);
        final availablePackages = offeringsAsync.valueOrNull?.current?.availablePackages ?? [];
        final singleCardPackage = availablePackages.firstWhereOrNull(
          (p) => p.storeProduct.identifier == 'rivon_single_card' || p.identifier == 'single_card' || p.identifier == 'single-card-purchase'
        );

        if (singleCardPackage != null) {
          final success = await ref.read(paymentControllerProvider.notifier).purchase(context, singleCardPackage);
          if (success) {
            _placeOrder(context: context, cardId: cardId, title: title, message: message, texts: texts);
          }
        } else {
          CustomSnackbar.showError(context, texts.singleCardNotAvailable);
        }
      }
    } finally {
      if (mounted) {
        state = const CardDetailState(isLoading: false);
      }
    }
  }

  void _placeOrder({
    required BuildContext context,
    required String cardId,
    required String title,
    required String message,
    required AppLocalizations texts,
  }) {
    final order = OrderEntity(
      cardId: cardId,
      title: title,
      message: message,
      addedAt: DateTime.now(),
    );
    ref.read(orderProvider.notifier).addOrder(order);
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
}

final cardDetailControllerProvider = StateNotifierProvider<CardDetailController, CardDetailState>((ref) {
  return CardDetailController(ref);
});
