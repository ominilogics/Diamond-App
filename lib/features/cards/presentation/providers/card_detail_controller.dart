import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../../features/payments/presentation/providers/payment_providers.dart';
import '../../../../features/payments/presentation/providers/payment_controller.dart';
import '../../data/repositories/sms_repository_impl.dart';
import '../../domain/entities/delivery_method.dart';

class CardDetailState {
  final bool isLoading;
  const CardDetailState({this.isLoading = false});
}

class CardDetailController extends StateNotifier<CardDetailState> {
  final Ref ref;

  CardDetailController(this.ref) : super(const CardDetailState());

  // ── Public Entry Point: Called from CardDetailScreen ──────────────────────
  Future<void> handlePurchaseAndOrder({
    required BuildContext context,
    required String cardId,
    required String title,
    required String message,
    required String from,
    required String to,
    required AppLocalizations texts,
    required PageController pageController,
    // These are populated only when the user is on page 2 (RecipientDeliveryForm)
    String? recipientPhone,
    DeliveryMethod? deliveryMethod,
    String? coverImageUrl,
    String? frontMessage,
  }) async {
    if (message.trim().isEmpty) {
      CustomSnackbar.showError(context, texts.pleaseEnterMessage);
      return;
    }

    if (recipientPhone == null || deliveryMethod == null) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    state = const CardDetailState(isLoading: true);

    try {
      CustomerInfo? customerInfo =
          ref.read(customerInfoStreamProvider).valueOrNull;
      if (customerInfo == null) {
        try {
          customerInfo = await Purchases.getCustomerInfo();
        } catch (_) {}
      }
      final hasActiveSubscription =
          customerInfo?.entitlements.active.containsKey('premium') ?? false;

      if (!context.mounted) return;

      if (hasActiveSubscription) {
        await _placeOrderAndSend(
          context: context,
          cardId: cardId,
          title: title,
          message: message,
          texts: texts,
          recipientPhone: recipientPhone,
          deliveryMethod: deliveryMethod,
          coverImageUrl: coverImageUrl,
          frontMessage: frontMessage,
          from: from,
        );
      } else {
        Offerings? offerings = ref.read(offeringsProvider).valueOrNull;
        if (offerings == null) {
          try {
            final res =
                await ref.read(paymentRepositoryProvider).fetchOfferings();
            offerings = res.fold((_) => null, (o) => o);
          } catch (_) {}
        }
        final availablePackages = offerings?.current?.availablePackages ?? [];
        final singleCardPackage = availablePackages.firstWhereOrNull(
          (p) =>
              p.storeProduct.identifier == 'rivon_single_card' ||
              p.storeProduct.identifier.startsWith('rivon_single_card') ||
              p.identifier == 'single_card' ||
              p.identifier == 'single-card-purchase',
        );

        if (!context.mounted) return;

        if (singleCardPackage != null) {
          final action = await showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (dialogCtx) => ConfirmationDialog(
              title: texts.cardDetails,
              message:
                  'A subscription or single-card purchase is required to send this card.',
              confirmText: 'Pay ${singleCardPackage.storeProduct.priceString}',
              cancelText: 'View Plans',
              onConfirm: () => Navigator.pop(dialogCtx, 'buy_single'),
              onCancel: () => Navigator.pop(dialogCtx, 'view_plans'),
            ),
          );

          if (!context.mounted) return;

          if (action == 'buy_single') {
            final success = await ref
                .read(paymentControllerProvider.notifier)
                .purchase(context, singleCardPackage);
            if (!context.mounted) return;
            if (success) {
              await _placeOrderAndSend(
                context: context,
                cardId: cardId,
                title: title,
                message: message,
                texts: texts,
                recipientPhone: recipientPhone,
                deliveryMethod: deliveryMethod,
                coverImageUrl: coverImageUrl,
                frontMessage: frontMessage,
                from: from,
              );
            }
          } else if (action == 'view_plans') {
            context.pushNamed(AppRoute.subscription.name);
          }
        } else {
          final goToPlans = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (dialogCtx) => ConfirmationDialog(
              title: 'Subscription Required',
              message:
                  'Subscribe to Rivon to send unlimited cards to your loved ones.',
              confirmText: 'View Plans',
              cancelText: 'Cancel',
              onConfirm: () => Navigator.pop(dialogCtx, true),
              onCancel: () => Navigator.pop(dialogCtx, false),
            ),
          );
          if (!context.mounted) return;
          if (goToPlans == true) {
            context.pushNamed(AppRoute.subscription.name);
          }
        }
      }
    } finally {
      if (mounted) {
        state = const CardDetailState(isLoading: false);
      }
    }
  }

  // ── Private: Place local order + optionally send via SMS/WhatsApp ─────────
  Future<void> _placeOrderAndSend({
    required BuildContext context,
    required String cardId,
    required String title,
    required String message,
    required String from,
    required AppLocalizations texts,
    String? recipientPhone,
    DeliveryMethod? deliveryMethod,
    String? coverImageUrl,
    String? frontMessage,
  }) async {
    // Save order locally first (always)
    final order = OrderEntity(
      cardId: cardId,
      title: title,
      message: message,
      addedAt: DateTime.now(),
    );
    ref.read(orderProvider.notifier).addOrder(order);

    // If the user provided a phone number, send the card via the chosen method
    if (recipientPhone != null &&
        recipientPhone.isNotEmpty &&
        deliveryMethod != null) {
      await _sendCardViaSms(
        context: context,
        recipientPhone: recipientPhone,
        senderName: from,
        coverImageUrl: coverImageUrl,
        frontMessage: frontMessage,
        insideMessage: message,
        method: deliveryMethod,
        texts: texts,
      );
    } else {
      // No delivery method: just show success and navigate
      CustomSnackbar.showSuccess(context, texts.orderPlaced);
      _navigateAfterOrder(context);
    }
  }

  // ── Private: Invoke SmsRepository and handle result ───────────────────────
  Future<void> _sendCardViaSms({
    required BuildContext context,
    required String recipientPhone,
    required String senderName,
    required String? coverImageUrl,
    required String? frontMessage,
    required String? insideMessage,
    required DeliveryMethod method,
    required AppLocalizations texts,
  }) async {
    // Resolve the sender's display name from Supabase auth profile
    final user = Supabase.instance.client.auth.currentUser;
    final displayName =
        senderName.isNotEmpty
            ? senderName
            : (user?.userMetadata?['display_name'] as String? ?? 'A friend');

    final result = await ref.read(smsRepositoryProvider).sendCard(
      recipientPhone: recipientPhone,
      senderName: displayName,
      coverImageUrl: coverImageUrl,
      frontMessage: frontMessage,
      insideMessage: insideMessage,
      method: method,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        // Map failure types to user-friendly messages
        final userMessage = failure is SmsFailure
            ? 'Could not send the card: ${failure.message}'
            : texts.orderPlaced; // Fallback: still placed locally
        CustomSnackbar.showError(context, userMessage);
        _navigateAfterOrder(context);
      },
      (_) {
        final channelName =
            method == DeliveryMethod.whatsApp ? 'WhatsApp' : 'SMS';
        CustomSnackbar.showSuccess(
          context,
          'Card sent via $channelName! 🎴',
        );
        _navigateAfterOrder(context);
      },
    );
  }

  // ── Private: Navigate to order history after success ──────────────────────
  void _navigateAfterOrder(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        context.goNamed(AppRoute.main.name);
        context.pushNamed(AppRoute.orderHistory.name);
      }
    });
  }
}

final cardDetailControllerProvider =
    StateNotifierProvider<CardDetailController, CardDetailState>((ref) {
  return CardDetailController(ref);
});
