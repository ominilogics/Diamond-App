import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/delivery_method.dart';

/// Abstract contract for the SMS repository.
/// The data layer implements this — the presentation layer depends on this abstraction only.
abstract class SmsRepository {
  /// Sends a card via SMS or WhatsApp.
  ///
  /// [recipientPhone] - E.164 formatted phone number (e.g. +117242758028)
  /// [senderName]     - Display name of the sender
  /// [coverImageUrl]  - URL of the card cover image
  /// [frontMessage]   - Text printed on the front of the card
  /// [insideMessage]  - Personalized message on the inside/back of the card
  /// [method]         - DeliveryMethod.sms or DeliveryMethod.whatsApp
  Future<Either<Failure, void>> sendCard({
    required String recipientPhone,
    required String senderName,
    required String? coverImageUrl,
    required String? frontMessage,
    required String? insideMessage,
    required DeliveryMethod method,
  });
}
