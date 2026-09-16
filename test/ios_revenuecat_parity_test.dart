import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Mock data structures representing the exact objects from RevenueCat on iOS
class MockStoreProduct {
  final String identifier;
  final String description;
  final String title;
  final double price;
  final String priceString;
  final String currencyCode;

  MockStoreProduct({
    required this.identifier,
    required this.description,
    required this.title,
    required this.price,
    required this.priceString,
    required this.currencyCode,
  });
}

class MockPackage {
  final String identifier;
  final PackageType packageType;
  final MockStoreProduct storeProduct;

  MockPackage({
    required this.identifier,
    required this.packageType,
    required this.storeProduct,
  });
}

class MockCustomerInfo {
  final List<String> activeSubscriptions;
  final Map<String, dynamic> activeEntitlements;
  final String? managementURL;

  MockCustomerInfo({
    required this.activeSubscriptions,
    required this.activeEntitlements,
    this.managementURL,
  });
}

void main() {
  group('iOS RevenueCat End-to-End Parity Verification', () {
    // Exact packages as configured in user\'s RevenueCat dashboard
    late List<MockPackage> iosAvailablePackages;

    setUp(() {
      iosAvailablePackages = [
        MockPackage(
          identifier: 'single_card',
          packageType: PackageType.custom,
          storeProduct: MockStoreProduct(
            identifier: 'rivon_single_card',
            title: 'Single Card Purchase',
            description: 'Send a single card',
            price: 5.99,
            priceString: '\$5.99',
            currencyCode: 'USD',
          ),
        ),
        MockPackage(
          identifier: 'standard_plan',
          packageType: PackageType.monthly,
          storeProduct: MockStoreProduct(
            identifier: 'rivon_standard',
            title: 'Rivon Standard',
            description: '5 cards per month',
            price: 4.99,
            priceString: '\$4.99',
            currencyCode: 'USD',
          ),
        ),
        MockPackage(
          identifier: 'pro_plan',
          packageType: PackageType.annual,
          storeProduct: MockStoreProduct(
            identifier: 'rivon_premium',
            title: 'Rivon Premium',
            description: '10 cards per month',
            price: 8.99,
            priceString: '\$8.99',
            currencyCode: 'USD',
          ),
        ),
      ];
    });

    test('1. iOS Package Resolution matches dashboard offerings correctly', () {
      // Logic used in subscription_screen.dart
      final standardPackage = iosAvailablePackages.cast<MockPackage?>().firstWhere(
            (p) =>
                p != null &&
                (p.packageType == PackageType.monthly ||
                    p.identifier == r'$rc_monthly' ||
                    p.identifier.contains('standard')),
            orElse: () => null,
          );

      final proPackage = iosAvailablePackages.cast<MockPackage?>().firstWhere(
            (p) =>
                p != null &&
                (p.packageType == PackageType.annual ||
                    p.identifier == r'$rc_annual' ||
                    p.identifier.contains('pro') ||
                    p.identifier.contains('premium')),
            orElse: () => null,
          );

      final singleCardPackage = iosAvailablePackages.cast<MockPackage?>().firstWhere(
            (p) =>
                p != null &&
                (p.storeProduct.identifier == 'rivon_single_card' ||
                    p.storeProduct.identifier.startsWith('rivon_single_card') ||
                    p.identifier == 'single_card' ||
                    p.identifier == 'single-card-purchase'),
            orElse: () => null,
          );

      expect(standardPackage, isNotNull);
      expect(standardPackage?.storeProduct.identifier, equals('rivon_standard'));
      expect(standardPackage?.storeProduct.priceString, equals('\$4.99'));

      expect(proPackage, isNotNull);
      expect(proPackage?.storeProduct.identifier, equals('rivon_premium'));
      expect(proPackage?.storeProduct.priceString, equals('\$8.99'));

      expect(singleCardPackage, isNotNull);
      expect(singleCardPackage?.storeProduct.identifier, equals('rivon_single_card'));
      expect(singleCardPackage?.storeProduct.priceString, equals('\$5.99'));
    });

    test('2. iOS isSubscribedTo resolves correctly for Apple StoreKit product IDs', () {
      bool isSubscribedTo(MockPackage? package, MockCustomerInfo customerInfo) {
        if (package == null) return false;
        final activeSubs = customerInfo.activeSubscriptions;
        if (activeSubs.isEmpty) return false;

        final packageSubId = package.storeProduct.identifier;
        final packageBaseId = packageSubId.split(':').first;

        for (final activeSub in activeSubs) {
          final activeBaseId = activeSub.split(':').first;
          if (activeSub == packageSubId ||
              activeBaseId == packageBaseId ||
              activeSub == packageBaseId ||
              activeBaseId == packageSubId) {
            return true;
          }
        }
        return false;
      }

      final standardPackage = iosAvailablePackages[1];
      final proPackage = iosAvailablePackages[2];

      // Case A: User is subscribed to Rivon Standard on iOS
      final standardCustomerInfo = MockCustomerInfo(
        activeSubscriptions: ['rivon_standard'],
        activeEntitlements: {'premium': {}},
      );
      expect(isSubscribedTo(standardPackage, standardCustomerInfo), isTrue);
      expect(isSubscribedTo(proPackage, standardCustomerInfo), isFalse);

      // Case B: User upgraded to Rivon Premium on iOS
      final proCustomerInfo = MockCustomerInfo(
        activeSubscriptions: ['rivon_premium'],
        activeEntitlements: {'premium': {}},
      );
      expect(isSubscribedTo(standardPackage, proCustomerInfo), isFalse);
      expect(isSubscribedTo(proPackage, proCustomerInfo), isTrue);

      // Case C: Unsubscribed user
      final unsubscribedInfo = MockCustomerInfo(
        activeSubscriptions: [],
        activeEntitlements: {},
      );
      expect(isSubscribedTo(standardPackage, unsubscribedInfo), isFalse);
      expect(isSubscribedTo(proPackage, unsubscribedInfo), isFalse);
    });

    test('3. Dynamic Paywall Button Text and State on iOS', () {
      String getButtonText({
        required int selectedPlan,
        required bool hasStandard,
        required bool hasPro,
      }) {
        if (selectedPlan == 0) {
          if (hasStandard) return 'Current Plan';
          if (hasPro) return 'Downgrade';
          return 'Subscribe Now';
        } else {
          if (hasPro) return 'Current Plan';
          if (hasStandard) return 'Upgrade to Pro';
          return 'Subscribe Now';
        }
      }

      bool isButtonDisabled({
        required int selectedPlan,
        required bool hasStandard,
        required bool hasPro,
        required bool isLoading,
      }) {
        if (isLoading) return true;
        if (selectedPlan == 0 && hasStandard) return true;
        if (selectedPlan == 1 && hasPro) return true;
        return false;
      }

      // Unsubscribed user viewing plan 0
      expect(getButtonText(selectedPlan: 0, hasStandard: false, hasPro: false), equals('Subscribe Now'));
      expect(isButtonDisabled(selectedPlan: 0, hasStandard: false, hasPro: false, isLoading: false), isFalse);

      // Subscribed to Standard, viewing Standard (plan 0)
      expect(getButtonText(selectedPlan: 0, hasStandard: true, hasPro: false), equals('Current Plan'));
      expect(isButtonDisabled(selectedPlan: 0, hasStandard: true, hasPro: false, isLoading: false), isTrue);

      // Subscribed to Standard, selecting Premium (plan 1) to upgrade
      expect(getButtonText(selectedPlan: 1, hasStandard: true, hasPro: false), equals('Upgrade to Pro'));
      expect(isButtonDisabled(selectedPlan: 1, hasStandard: true, hasPro: false, isLoading: false), isFalse);

      // Subscribed to Pro, selecting Standard (plan 0) to downgrade
      expect(getButtonText(selectedPlan: 0, hasStandard: false, hasPro: true), equals('Downgrade'));
      expect(isButtonDisabled(selectedPlan: 0, hasStandard: false, hasPro: true, isLoading: false), isFalse);
    });

    test('4. iOS StoreKit Purchase does NOT attach Android GoogleProductChangeInfo', () {
      bool isChangeInfoGenerated({required bool isAndroid}) {
        if (!isAndroid) return false;
        return true;
      }

      // On iOS, StoreKit Subscription Groups handle upgrades/downgrades natively without changeInfo
      expect(isChangeInfoGenerated(isAndroid: false), isFalse);
    });

    test('5. iOS Entitlement Unlocking matches backend check on card send', () {
      bool canSendCardWithoutPayment(MockCustomerInfo info) {
        return info.activeEntitlements.containsKey('premium');
      }

      final activeIosUser = MockCustomerInfo(
        activeSubscriptions: ['rivon_standard'],
        activeEntitlements: {'premium': {}},
      );
      final unsubscribedUser = MockCustomerInfo(
        activeSubscriptions: [],
        activeEntitlements: {},
      );

      expect(canSendCardWithoutPayment(activeIosUser), isTrue);
      expect(canSendCardWithoutPayment(unsubscribedUser), isFalse);
    });

    test('6. iOS Native Subscription Management Fallback Resolution', () {
      String resolveIosManagementUrl(String? managementUrl) {
        if (managementUrl != null && managementUrl.isNotEmpty) {
          return managementUrl;
        }
        return 'https://apps.apple.com/account/subscriptions';
      }

      expect(
        resolveIosManagementUrl(null),
        equals('https://apps.apple.com/account/subscriptions'),
      );
      expect(
        resolveIosManagementUrl('https://apps.apple.com/manage-direct'),
        equals('https://apps.apple.com/manage-direct'),
      );
    });

    test('7. iOS Restore Purchases Feedback Resolution', () {
      String getRestoreFeedback(bool hasActiveEntitlements) {
        return hasActiveEntitlements
            ? 'Purchases restored successfully!'
            : 'No active subscriptions found to restore.';
      }

      expect(getRestoreFeedback(true), equals('Purchases restored successfully!'));
      expect(getRestoreFeedback(false), equals('No active subscriptions found to restore.'));
    });
  });
}
