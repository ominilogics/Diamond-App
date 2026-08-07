import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/delivery_method.dart';
import '../../domain/repositories/sms_repository.dart';

// BYPASS TESTING: Native Android share sheet via MethodChannel.
// No new packages — uses a platform channel wired in MainActivity.kt.
// To revert: delete the _shareChannel constant and the bypass block,
// uncomment the PRODUCTION block, and revert MainActivity.kt.
const _shareChannel = MethodChannel(
  'com.greetingcards.invitationmaker.rivon/share',
);

class SmsRepositoryImpl implements SmsRepository {
  // BYPASS TESTING: _client is kept to preserve the full production signature
  // but is not used while the MethodChannel bypass is active.
  // ignore: unused_field
  final SupabaseClient _client;

  SmsRepositoryImpl(this._client);

  @override
  Future<Either<Failure, void>> sendCard({
    required String recipientPhone,
    required String senderName,
    required String? coverImageUrl,
    required String? frontMessage,
    required String? insideMessage,
    required DeliveryMethod method,
  }) async {
    try {
      // ── 1. Build the Base64 encoded deep link payload ────────────────────
      final payload = {
        'coverImageUrl': coverImageUrl ?? '',
        'frontMessage': frontMessage ?? '',
        'message': insideMessage ?? '',
      };
      // base64Url encodes safely for URLs, but we URL encode just in case to avoid any issues with Intents
      final encoded = Uri.encodeComponent(base64Url.encode(utf8.encode(jsonEncode(payload))));
      final url = 'https://rivon-62e8a.web.app/open-card?data=$encoded';

      // ── 2. BYPASS: Open Android native share sheet ────────────────────────
      // ── BYPASS START ──────────────────────────────────────────────────────
      final channelLabel =
          method == DeliveryMethod.whatsApp ? 'WhatsApp' : 'SMS';
      final messageBody =
          '✉️ $senderName sent you a digital card via $channelLabel! '
          'Tap the link below to open it 🎴\n\n$url';

      await _shareChannel.invokeMethod<void>(
        'shareText',
        {'text': messageBody},
      );

      return Either.right(null);
      // ── BYPASS END ────────────────────────────────────────────────────────

      // ── PRODUCTION: Invoke the Supabase Edge Function (commented out) ─────
      // final response = await _client.functions.invoke(
      //   'send-sms',
      //   body: {
      //     'toPhoneNumber': recipientPhone,
      //     'senderName': senderName,
      //     'deepLinkUrl': deepLinkUrl,
      //     'method': method == DeliveryMethod.whatsApp ? 'whatsApp' : 'sms',
      //   },
      // );
      //
      // final responseData = response.data;
      // if (responseData is Map && responseData.containsKey('error')) {
      //   return Either.left(
      //     SmsFailure(
      //         responseData['error'] as String? ?? 'Failed to send message.'),
      //   );
      // }
      //
      // return Either.right(null);
    } on PlatformException catch (e) {
      return Either.left(
        SmsFailure('Could not open share sheet: ${e.message}'),
      );
    } on FunctionException catch (e) {
      return Either.left(
        SmsFailure(e.details?.toString() ?? 'Edge function error: ${e.status}'),
      );
    } catch (e) {
      return Either.left(
        SmsFailure('An unexpected error occurred while sending the card.'),
      );
    }
  }
}

/// Riverpod provider for dependency injection.
final smsRepositoryProvider = Provider<SmsRepository>((ref) {
  return SmsRepositoryImpl(Supabase.instance.client);
});
