import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:daimond/core/error/failures.dart';
import 'package:daimond/core/utils/either.dart';
import 'package:daimond/features/payments/domain/repositories/payment_repository.dart';

class RevenueCatRepositoryImpl implements PaymentRepository {
  static const _appleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
    defaultValue: 'appl_vFUZVyiLHNutpKkTijxKtarljun',
  );
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
      return Either.left(PaymentFailure(e.message ?? 'Failed to logout user from payments.'));
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
      return Either.left(PaymentFailure(e.message ?? 'Failed to fetch offerings.'));
    } catch (e) {
      return Either.left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> purchasePackage(Package package) async {
    try {
      final PurchaseResult purchaseResult;

      // Google Play Subscription upgrade/downgrade proration logic
      if (Platform.isAndroid &&
          package.packageType != PackageType.unknown &&
          package.packageType != PackageType.custom) {
        CustomerInfo? currentInfo;
        try {
          currentInfo = await Purchases.getCustomerInfo();
        } catch (_) {}

        GoogleProductChangeInfo? changeInfo;
        final activeSubs = currentInfo?.activeSubscriptions ?? [];
        if (activeSubs.isNotEmpty) {
          final targetBaseId = package.storeProduct.identifier.split(':').first;
          final currentActiveSub = activeSubs.firstWhereOrNull((sub) {
            final activeBaseId = sub.split(':').first;
            return activeBaseId != targetBaseId;
          });

          if (currentActiveSub != null) {
            final oldProductBaseId = currentActiveSub.split(':').first;
            changeInfo = GoogleProductChangeInfo(
              oldProductBaseId,
              prorationMode: GoogleProrationMode.immediateWithTimeProration,
            );
          }
        }

        purchaseResult = await Purchases.purchasePackage(
          package,
          googleProductChangeInfo: changeInfo,
        );
      } else {
        // iOS StoreKit (handles Subscription Groups upgrades natively) or non-subscription package
        purchaseResult = await Purchases.purchasePackage(package);
      }

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
      final hasActiveEntitlements = customerInfo.entitlements.active.isNotEmpty;
      return Either.right(hasActiveEntitlements);
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
          return Either.right(null);
        }
      }

      // Fallback URLs if RevenueCat managementURL is not provided
      final fallbackUrl = Platform.isAndroid 
          ? Uri.parse("https://play.google.com/store/account/subscriptions")
          : Uri.parse("https://apps.apple.com/account/subscriptions");
          
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        return Either.right(null);
      }
      
      return Either.left(PaymentFailure('Could not open subscription manager.'));
    } catch (e) {
      return Either.left(PaymentFailure(e.toString()));
    }
  }
}
