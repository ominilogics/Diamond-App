import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Isolated logic extractor replicating the subscription screen matching logic
bool isSubscribedTo({
  required String? productId,
  required List<String> activeSubscriptions,
  Map<String, EntitlementInfo> activeEntitlements = const {},
}) {
  if (productId == null) return false;
  final baseId = productId.split(':').first;
  return activeSubscriptions.any(
    (sub) => sub == productId || sub.split(':').first == baseId,
  );
}

/// Helper replicating the RevenueCat repository upgrade/downgrade changeInfo generation
GoogleProductChangeInfo? computeGoogleProductChangeInfo({
  required bool isAndroid,
  required List<String> activeSubscriptions,
  required String targetProductId,
  required PackageType packageType,
}) {
  if (!isAndroid || activeSubscriptions.isEmpty) return null;

  final newBasePlan = targetProductId.split(':').first;
  final isSubscription = packageType != PackageType.custom &&
      packageType != PackageType.unknown;

  if (!isSubscription) return null;

  final oldSub = activeSubscriptions.cast<String?>().firstWhere(
    (sub) => sub != null && sub.split(':').first != newBasePlan,
    orElse: () => null,
  );

  if (oldSub != null) {
    final oldSubscriptionId = oldSub.split(':').first;
    return GoogleProductChangeInfo(
      oldSubscriptionId,
      prorationMode: GoogleProrationMode.immediateWithTimeProration,
    );
  }

  return null;
}

/// Simulated Decision Matrix for CardDetail / EditCard Controllers
enum PaymentGateAction {
  placeOrderDirectly,
  promptSingleOrSubscription,
  promptSubscriptionOnly,
  navigateToRecipientPage,
}

PaymentGateAction evaluatePaymentGate({
  required bool hasActivePremiumEntitlement,
  required bool hasRecipientInfo,
  required bool isSingleCardPackageAvailable,
}) {
  if (!hasRecipientInfo) {
    return PaymentGateAction.navigateToRecipientPage;
  }
  if (hasActivePremiumEntitlement) {
    return PaymentGateAction.placeOrderDirectly;
  }
  if (isSingleCardPackageAvailable) {
    return PaymentGateAction.promptSingleOrSubscription;
  }
  return PaymentGateAction.promptSubscriptionOnly;
}

void main() {
  group('1. Google Play Base-Plan Robust Matching Tests', () {
    test('Matches standard subscription with identical ID', () {
      final matched = isSubscribedTo(
        productId: 'rivon_standard',
        activeSubscriptions: ['rivon_standard'],
      );
      expect(matched, isTrue);
    });

    test('Matches Google Play v5+ base plan format: productId:basePlanId when active is baseId', () {
      final matched = isSubscribedTo(
        productId: 'rivon_standard:monthly-standard',
        activeSubscriptions: ['rivon_standard'],
      );
      expect(matched, isTrue);
    });

    test('Matches when active subscription contains base plan tag and package is baseId', () {
      final matched = isSubscribedTo(
        productId: 'rivon_pro',
        activeSubscriptions: ['rivon_pro:yearly-discount'],
      );
      expect(matched, isTrue);
    });

    test('Matches when both have different base plan tags on the same base subscription ID', () {
      final matched = isSubscribedTo(
        productId: 'rivon_standard:promo-tier',
        activeSubscriptions: ['rivon_standard:standard-base'],
      );
      expect(matched, isTrue);
    });

    test('Rejects when product does not match active subscription', () {
      final matched = isSubscribedTo(
        productId: 'rivon_pro:yearly',
        activeSubscriptions: ['rivon_standard'],
      );
      expect(matched, isFalse);
    });

    test('Rejects gracefully when productId is null', () {
      final matched = isSubscribedTo(
        productId: null,
        activeSubscriptions: ['rivon_standard'],
      );
      expect(matched, isFalse);
    });

    test('Rejects gracefully when activeSubscriptions is empty', () {
      final matched = isSubscribedTo(
        productId: 'rivon_standard',
        activeSubscriptions: [],
      );
      expect(matched, isFalse);
    });
  });

  group('2. Google Play Upgrade/Downgrade Proration Tests', () {
    test('Generates GoogleProductChangeInfo on Android when upgrading standard -> pro', () {
      final changeInfo = computeGoogleProductChangeInfo(
        isAndroid: true,
        activeSubscriptions: ['rivon_standard'],
        targetProductId: 'rivon_pro:yearly',
        packageType: PackageType.annual,
      );

      expect(changeInfo, isNotNull);
      expect(changeInfo?.oldProductIdentifier, equals('rivon_standard'));
      expect(
        changeInfo?.prorationMode,
        equals(GoogleProrationMode.immediateWithTimeProration),
      );
    });

    test('Extracts base ID properly when active subscription has tag (rivon_standard:p1m -> rivon_pro)', () {
      final changeInfo = computeGoogleProductChangeInfo(
        isAndroid: true,
        activeSubscriptions: ['rivon_standard:p1m'],
        targetProductId: 'rivon_pro',
        packageType: PackageType.annual,
      );

      expect(changeInfo, isNotNull);
      expect(changeInfo?.oldProductIdentifier, equals('rivon_standard'));
    });

    test('Does NOT generate changeInfo when purchasing the same base plan', () {
      final changeInfo = computeGoogleProductChangeInfo(
        isAndroid: true,
        activeSubscriptions: ['rivon_standard:base1'],
        targetProductId: 'rivon_standard:base2',
        packageType: PackageType.monthly,
      );

      expect(changeInfo, isNull);
    });

    test('Does NOT generate changeInfo when purchasing non-subscription consumable (single card)', () {
      final changeInfo = computeGoogleProductChangeInfo(
        isAndroid: true,
        activeSubscriptions: ['rivon_standard'],
        targetProductId: 'rivon_single_card',
        packageType: PackageType.custom,
      );

      expect(changeInfo, isNull);
    });

    test('Does NOT generate changeInfo when user has no active subscriptions', () {
      final changeInfo = computeGoogleProductChangeInfo(
        isAndroid: true,
        activeSubscriptions: [],
        targetProductId: 'rivon_standard:monthly',
        packageType: PackageType.monthly,
      );

      expect(changeInfo, isNull);
    });

    test('Does NOT generate changeInfo when platform is not Android', () {
      final changeInfo = computeGoogleProductChangeInfo(
        isAndroid: false,
        activeSubscriptions: ['rivon_standard'],
        targetProductId: 'rivon_pro:yearly',
        packageType: PackageType.annual,
      );

      expect(changeInfo, isNull);
    });
  });

  group('3. Payment Gate Decision Matrix Tests', () {
    test('Missing recipient details redirects to page 2 without charging', () {
      final action = evaluatePaymentGate(
        hasActivePremiumEntitlement: true,
        hasRecipientInfo: false,
        isSingleCardPackageAvailable: true,
      );
      expect(action, equals(PaymentGateAction.navigateToRecipientPage));
    });

    test('Active premium subscriber immediately places order', () {
      final action = evaluatePaymentGate(
        hasActivePremiumEntitlement: true,
        hasRecipientInfo: true,
        isSingleCardPackageAvailable: true,
      );
      expect(action, equals(PaymentGateAction.placeOrderDirectly));
    });

    test('Unsubscribed user with single card available prompts with single or subscription choice', () {
      final action = evaluatePaymentGate(
        hasActivePremiumEntitlement: false,
        hasRecipientInfo: true,
        isSingleCardPackageAvailable: true,
      );
      expect(action, equals(PaymentGateAction.promptSingleOrSubscription));
    });

    test('Unsubscribed user without single card available prompts with subscription view plans', () {
      final action = evaluatePaymentGate(
        hasActivePremiumEntitlement: false,
        hasRecipientInfo: true,
        isSingleCardPackageAvailable: false,
      );
      expect(action, equals(PaymentGateAction.promptSubscriptionOnly));
    });
  });

  group('4. iOS RevenueCat & StoreKit 2 Parity Tests', () {
    test('iOS purchases bypass GoogleProductChangeInfo to let StoreKit manage subscription groups natively', () {
      final changeInfo = computeGoogleProductChangeInfo(
        isAndroid: false,
        activeSubscriptions: ['rivon_standard'],
        targetProductId: 'rivon_premium',
        packageType: PackageType.annual,
      );

      // On iOS, StoreKit 2 natively handles upgrade/downgrade in subscription groups
      expect(changeInfo, isNull);
    });

    test('iOS restore purchases differentiates between active entitlements and empty state', () {
      bool evaluateRestoreStatus(Map<String, dynamic> activeEntitlements) {
        return activeEntitlements.isNotEmpty;
      }

      expect(evaluateRestoreStatus({'premium': {}}), isTrue);
      expect(evaluateRestoreStatus({}), isFalse);
    });

    test('Package identifier matching works for standard_plan and pro_plan on iOS', () {
      bool isStandard(String id) =>
          id == r'$rc_monthly' || id.contains('standard');
      bool isPro(String id) =>
          id == r'$rc_annual' || id.contains('pro') || id.contains('premium');

      expect(isStandard('standard_plan'), isTrue);
      expect(isStandard('rivon_standard'), isTrue);
      expect(isPro('pro_plan'), isTrue);
      expect(isPro('rivon_premium'), isTrue);
    });

    test('iOS management URL falls back to App Store subscription URL', () {
      String resolveManagementUrl({String? revenueCatUrl, required bool isIos}) {
        if (revenueCatUrl != null && revenueCatUrl.isNotEmpty) {
          return revenueCatUrl;
        }
        return isIos
            ? 'https://apps.apple.com/account/subscriptions'
            : 'https://play.google.com/store/account/subscriptions';
      }

      expect(
        resolveManagementUrl(revenueCatUrl: null, isIos: true),
        equals('https://apps.apple.com/account/subscriptions'),
      );
      expect(
        resolveManagementUrl(
          revenueCatUrl: 'https://custom.revenuecat.com/manage',
          isIos: true,
        ),
        equals('https://custom.revenuecat.com/manage'),
      );
    });
  });
}
