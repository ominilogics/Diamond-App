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

// BYPASS TESTING: Native Android share sheet via MethodChannel.
// No new packages — uses a platform channel wired in MainActivity.kt.
// To revert: delete the _shareChannel constant and the bypass block,
// uncomment the PRODUCTION block, and revert MainActivity.kt.
const _shareChannel = MethodChannel(
  'com.greetingcards.invitationmaker.rivon/share',
);

String _generateShortCode([int length = 6]) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

class SmsRepositoryImpl implements SmsRepository {
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
      // ── 1. Attempt to generate short URL via Supabase shared_cards ──────────
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

