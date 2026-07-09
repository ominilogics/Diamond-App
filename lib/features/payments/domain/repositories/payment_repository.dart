import 'package:daimond/core/error/failures.dart';
import 'package:daimond/core/utils/either.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class PaymentRepository {
  /// Initialize the RevenueCat SDK
  Future<Either<Failure, void>> initialize();

  /// Bind the user's Supabase ID to RevenueCat
  Future<Either<Failure, void>> loginUser(String userId);

  /// Unbind the user on logout
  Future<Either<Failure, void>> logoutUser();

  /// Fetch the active offerings (subscriptions and cards)
  Future<Either<Failure, Offerings>> fetchOfferings();

  /// Purchase a specific package
  Future<Either<Failure, bool>> purchasePackage(Package package);

  /// Restore previous purchases
  Future<Either<Failure, bool>> restorePurchases();

  /// Launch the native OS subscription management screen for cancellations
  Future<Either<Failure, void>> manageSubscriptions();

  /// Stream to listen to real-time changes in user entitlements
  Stream<CustomerInfo> get customerInfoStream;
}
