import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:daimond/features/payments/domain/repositories/payment_repository.dart';
import 'package:daimond/features/payments/data/repositories/revenue_cat_repository_impl.dart';

/// Provides the core payment repository implementation
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return RevenueCatRepositoryImpl();
});

/// A continuous stream of the user's entitlements (Premium status, owned cards, etc.)
/// This is the backbone of the UI. If a user buys something, this stream updates, 
/// and all locked widgets instantly unlock.
final customerInfoStreamProvider = StreamProvider<CustomerInfo>((ref) async* {
  final repository = ref.watch(paymentRepositoryProvider);
  
  // Yield the initial local state first so UI doesn't wait
  try {
    final initialInfo = await Purchases.getCustomerInfo();
    yield initialInfo;
  } catch (_) {
    // Ignore errors here, the stream will catch subsequent updates
  }

  // Yield all future updates
  yield* repository.customerInfoStream;
});

/// Fetches the available store offerings from RevenueCat
final offeringsProvider = FutureProvider<Offerings>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  final result = await repository.fetchOfferings();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (offerings) => offerings,
  );
});

/// A simple helper provider to quickly check if the user is a Pro subscriber
final isProSubscriberProvider = Provider<bool>((ref) {
  final customerInfo = ref.watch(customerInfoStreamProvider).valueOrNull;
  if (customerInfo == null) return false;
  
  // Checking the 'premium' entitlement
  return customerInfo.entitlements.active.containsKey('premium');
});
