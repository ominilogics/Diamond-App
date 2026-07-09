import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:daimond/core/error/failures.dart';
import 'package:daimond/core/utils/either.dart';
import 'package:daimond/features/payments/domain/repositories/payment_repository.dart';

class RevenueCatRepositoryImpl implements PaymentRepository {
  /// TODO: Replace these with your actual RevenueCat API keys
  static const _appleApiKey = 'appl_api_key_here';
  static const _googleApiKey = 'goog_TURcJjGEgzGKRgInkfBLNxXsjvh';

  final StreamController<CustomerInfo> _customerInfoController = StreamController<CustomerInfo>.broadcast();

  RevenueCatRepositoryImpl() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _customerInfoController.add(customerInfo);
    });
  }

  @override
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      } else {
        return Either.left(PaymentFailure('Unsupported platform for payments.'));
      }

      await Purchases.configure(configuration);
      return Either.right(null);
    } on PlatformException catch (e) {
      return Either.left(PaymentFailure(e.message ?? 'Failed to initialize payments.'));
    } catch (e) {
      return Either.left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> loginUser(String userId) async {
    try {
      final logInResult = await Purchases.logIn(userId);
      _customerInfoController.add(logInResult.customerInfo);
      return Either.right(null);
    } on PlatformException catch (e) {
      return Either.left(PaymentFailure(e.message ?? 'Failed to sync user with payments.'));
    } catch (e) {
      return Either.left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logoutUser() async {
    try {
      final customerInfo = await Purchases.logOut();
      _customerInfoController.add(customerInfo);
      return Either.right(null);
    } on PlatformException catch (e) {
      return Either.left(PaymentFailure(e.message ?? 'Failed to logout from payments.'));
    } catch (e) {
      return Either.left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Offerings>> fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return Either.right(offerings);
    } on PlatformException catch (e) {
      return Either.left(PaymentFailure(e.message ?? 'Failed to fetch store offerings.'));
    } catch (e) {
      return Either.left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> purchasePackage(Package package) async {
    try {
      debugPrint('[PaymentRepo] Starting purchase for package: ${package.identifier}');
      final customerInfo = await Purchases.getCustomerInfo();
      final activeSubscriptions = customerInfo.activeSubscriptions;
      debugPrint('[PaymentRepo] Current active subscriptions: $activeSubscriptions');

      GoogleProductChangeInfo? changeInfo;
      // If the user already has an active subscription, and they are buying a different subscription package
      // we must provide the old product ID to Google Play so it performs an upgrade/downgrade instead of throwing an error.
      if (Platform.isAndroid && activeSubscriptions.isNotEmpty) {
        final oldProduct = activeSubscriptions.first;
        if (oldProduct != package.storeProduct.identifier) {
          debugPrint('[PaymentRepo] Detected upgrade/downgrade from $oldProduct to ${package.storeProduct.identifier}');
          changeInfo = GoogleProductChangeInfo(
            oldProduct,
            prorationMode: GoogleProrationMode.immediateWithTimeProration,
          );
        }
      }

      debugPrint('[PaymentRepo] Calling Purchases.purchasePackage...');
      final purchaseResult = await Purchases.purchasePackage(
        package,
        googleProductChangeInfo: changeInfo,
      );
      debugPrint('[PaymentRepo] Purchase successful for package: ${package.identifier}');
      _customerInfoController.add(purchaseResult.customerInfo);
      return Either.right(true);
    } on PlatformException catch (e) {
      debugPrint('[PaymentRepo] PlatformException during purchase: Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
      final isCancelled = e.code == PurchasesErrorCode.purchaseCancelledError.toString();
      return Either.left(PaymentFailure(e.message ?? 'Purchase failed.', isCancelled: isCancelled));
    } catch (e) {
      debugPrint('[PaymentRepo] Unknown exception during purchase: $e');
      return Either.left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _customerInfoController.add(customerInfo);
      return Either.right(true);
    } on PlatformException catch (e) {
      return Either.left(PaymentFailure(e.message ?? 'Failed to restore purchases.'));
    } catch (e) {
      return Either.left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> manageSubscriptions() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final managementURL = customerInfo.managementURL;

      if (managementURL != null) {
        final uri = Uri.parse(managementURL);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return  Either.right(null);
        }
      }

      // Fallback URLs if RevenueCat doesn't have it
      final fallbackUrl = Platform.isAndroid 
          ? Uri.parse("https://play.google.com/store/account/subscriptions")
          : Uri.parse("https://apps.apple.com/account/subscriptions");
          
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        return  Either.right(null);
      }
      
      return Either.left(PaymentFailure('Could not open subscription manager.'));
    } catch (e) {
      return Either.left(PaymentFailure(e.toString()));
    }
  }
}
