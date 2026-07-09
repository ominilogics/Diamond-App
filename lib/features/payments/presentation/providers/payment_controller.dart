import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:daimond/core/widgets/custom_snackbar.dart';
import 'package:daimond/l10n/app_localizations.dart';
import 'package:daimond/core/error/failures.dart';
import 'package:daimond/features/payments/presentation/providers/payment_providers.dart';
import 'package:flutter/material.dart';

class PaymentController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  PaymentController(this._ref) : super(const AsyncValue.data(null));

  /// Purchase a package and handle UI loading states and errors safely
  Future<bool> purchase(BuildContext context, Package package) async {
    state = const AsyncValue.loading();

    final repository = _ref.read(paymentRepositoryProvider);
    final result = await repository.purchasePackage(package);

    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        if (failure is PaymentFailure && !failure.isCancelled) {
          // Only show error if it wasn't an intentional user cancellation
          CustomSnackbar.showError(context, failure.message);
        }
        return false;
      },
      (success) {
        state = const AsyncValue.data(null);
        CustomSnackbar.showSuccess(context, AppLocalizations.of(context)!.purchaseSuccessful);
        return true;
      },
    );
  }

  /// Restore previous purchases
  Future<void> restorePurchases(BuildContext context) async {
    state = const AsyncValue.loading();

    final repository = _ref.read(paymentRepositoryProvider);
    final result = await repository.restorePurchases();

    result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        CustomSnackbar.showError(context, failure.message);
      },
      (success) {
        state = const AsyncValue.data(null);
        CustomSnackbar.showSuccess(context, AppLocalizations.of(context)!.restoreSuccessful);
      },
    );
  }

  /// Launch the native OS subscription manager
  Future<void> manageSubscriptions(BuildContext context) async {
    state = const AsyncValue.loading();
    final repository = _ref.read(paymentRepositoryProvider);
    final result = await repository.manageSubscriptions();

    result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        CustomSnackbar.showError(context, failure.message);
      },
      (success) {
        state = const AsyncValue.data(null);
        // We don't show a success message because the OS handles the UI flow
      },
    );
  }
}

final paymentControllerProvider = StateNotifierProvider<PaymentController, AsyncValue<void>>((ref) {
  return PaymentController(ref);
});
