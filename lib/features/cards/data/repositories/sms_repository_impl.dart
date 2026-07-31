import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/delivery_method.dart';
import '../../domain/repositories/sms_repository.dart';

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
      // ── 1. Build the Base64 encoded deep link payload ────────────────────
      // We encode all card data into the URL so the recipient can view the
      // exact same card without us needing to store it server-side.
      final payload = {
        'coverImageUrl': coverImageUrl ?? '',
        'frontMessage': frontMessage ?? '',
        'message': insideMessage ?? '',
      };
      final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
      
      // Build the Edge Function URL dynamically from environment variables
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final edgeFunctionBaseUrl = '$supabaseUrl/functions/v1/open-card';
      final deepLinkUrl = '$edgeFunctionBaseUrl?data=$encoded';

      // ── 2. Invoke the Supabase Edge Function ─────────────────────────────
      final response = await _client.functions.invoke(
        'send-sms',
        body: {
          'toPhoneNumber': recipientPhone,
          'senderName': senderName,
          'deepLinkUrl': deepLinkUrl,
          'method': method == DeliveryMethod.whatsApp ? 'whatsApp' : 'sms',
        },
      );

      // ── 3. Handle edge function errors ────────────────────────────────────
      final responseData = response.data;
      if (responseData is Map && responseData.containsKey('error')) {
        return Either.left(
          SmsFailure(responseData['error'] as String? ?? 'Failed to send message.'),
        );
      }

      return Either.right(null);
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
/// Inject this anywhere in the presentation layer.
final smsRepositoryProvider = Provider<SmsRepository>((ref) {
  return SmsRepositoryImpl(Supabase.instance.client);
});
