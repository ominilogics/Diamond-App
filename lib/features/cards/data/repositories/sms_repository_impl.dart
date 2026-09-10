import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/delivery_method.dart';
import '../../domain/repositories/sms_repository.dart';

/// Platform channel for native Android/iOS share sheet fallback
const _shareChannel = MethodChannel(
  'com.greetingcards.invitationmaker.rivon/share',
);

/// Helper: Generate random 6-character short code for Supabase shared_cards table
String _generateShortCode([int length = 6]) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

class SmsRepositoryImpl implements SmsRepository {
  final SupabaseClient _client;

  /// Toggle between direct Twilio Edge Function dispatch and Native OS Share Sheet.
  /// Set to `false` for zero-cost local testing via Share Sheet, or `true` for direct Twilio SMS/WhatsApp dispatches.
  final bool useTwilioBackend;

  SmsRepositoryImpl(this._client, {this.useTwilioBackend = false});

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
      // ── 1. Generate short URL via Supabase shared_cards ─────────────────────
      String url;
      try {
        final shortCode = _generateShortCode(6);
        await _client.from('shared_cards').insert({
          'code': shortCode,
          'cover_image_url': coverImageUrl ?? '',
          'front_message': frontMessage ?? '',
          'inside_message': insideMessage ?? '',
        }).timeout(const Duration(seconds: 3));

        url = 'https://rivon-62e8a.web.app/open-card?c=$shortCode';
        debugPrint('[SMS REPO] Successfully generated short URL: $url');
      } catch (e) {
        debugPrint('[SMS REPO] Short URL generation failed/timed out, using Base64 fallback: $e');
        // Fallback to legacy Base64 URL format if DB insert fails or device is offline
        final payload = {
          'coverImageUrl': coverImageUrl ?? '',
          'frontMessage': frontMessage ?? '',
          'message': insideMessage ?? '',
        };
        final encoded = Uri.encodeComponent(base64Url.encode(utf8.encode(jsonEncode(payload))));
        url = 'https://rivon-62e8a.web.app/open-card?data=$encoded';
      }

      // ── 2. Dispatch via Twilio Edge Function OR Native Share Sheet ─────────
      if (useTwilioBackend) {
        // Direct Server-Side Dispatch via Supabase Edge Function `send-sms`
        final response = await _client.functions.invoke(
          'send-sms',
          body: {
            'toPhoneNumber': recipientPhone,
            'senderName': senderName,
            'deepLinkUrl': url,
            'method': method == DeliveryMethod.whatsApp ? 'whatsApp' : 'sms',
          },
        );

        if (response.status != 200) {
          final data = response.data;
          final errorMsg = (data is Map && data.containsKey('error'))
              ? data['error'].toString()
              : 'Failed to send message via Twilio (HTTP ${response.status})';
          return Either.left(SmsFailure(errorMsg));
        }

        return Either.right(null);
      } else {
        // Zero-Cost Local Testing Fallback: Native OS Share Sheet (Intent.ACTION_SEND)
        final channelLabel = method == DeliveryMethod.whatsApp ? 'WhatsApp' : 'SMS';
        final messageBody =
            '✉️ $senderName sent you a digital card via $channelLabel! '
            'Tap the link below to open it 🎴\n\n$url';

        await _shareChannel.invokeMethod<void>(
          'shareText',
          {'text': messageBody},
        );

        return Either.right(null);
      }
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
        SmsFailure('An unexpected error occurred while sending the card: $e'),
      );
    }
  }
}

/// Riverpod provider for dependency injection.
final smsRepositoryProvider = Provider<SmsRepository>((ref) {
  return SmsRepositoryImpl(Supabase.instance.client, useTwilioBackend: false);
});
