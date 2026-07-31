import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daimond/l10n/app_localizations.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
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
    if (from.trim().isEmpty || to.trim().isEmpty) {
      pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    state = const CardDetailState(isLoading: true);

    try {
      final customerInfo = ref.read(customerInfoStreamProvider).valueOrNull;
      final hasActiveSubscription =
          customerInfo?.entitlements.active.containsKey('premium') ?? false;

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
        final offeringsAsync = ref.read(offeringsProvider);
        final availablePackages =
            offeringsAsync.valueOrNull?.current?.availablePackages ?? [];
        final singleCardPackage = availablePackages.firstWhereOrNull(
          (p) =>
              p.storeProduct.identifier == 'rivon_single_card' ||
              p.identifier == 'single_card' ||
              p.identifier == 'single-card-purchase',
        );

        if (singleCardPackage != null) {
          final success = await ref
              .read(paymentControllerProvider.notifier)
              .purchase(context, singleCardPackage);
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
