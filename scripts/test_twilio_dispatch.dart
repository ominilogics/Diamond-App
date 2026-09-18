import 'package:supabase/supabase.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? anonKey;
  String? serviceRoleKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1].trim();
    if (line.startsWith('SUPABASE_ANON_KEY=')) anonKey = line.split('=')[1].trim();
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceRoleKey = line.split('=')[1].trim();
  }

  if (url == null || serviceRoleKey == null) {
    print('Error: Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env');
    exit(1);
  }

  // Use anon client for standard function calls
  final anonClient = SupabaseClient(url, anonKey ?? serviceRoleKey);
  final adminClient = SupabaseClient(url, serviceRoleKey);

  final userPhone = '+923121946942';
  final deepLink = 'https://rivon-62e8a.web.app/open-card?c=test01';

  print('1. Creating user auth session...');
  String userJwt = serviceRoleKey;
  try {
    final authRes = await adminClient.auth.signInAnonymously();
    if (authRes.session != null) {
      userJwt = authRes.session!.accessToken;
      print('User session acquired: ${authRes.user?.id}');
    }
  } catch (e) {
    print('Auth error: $e');
  }

  print('\n2. Testing direct HTTP POST to Edge Function...');
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('$url/functions/v1/send-sms'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('apikey', serviceRoleKey);
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');

    final payload = jsonEncode({
      'toPhoneNumber': userPhone,
      'senderName': 'Rivon Test Sender',
      'deepLinkUrl': deepLink,
      'method': 'whatsApp',
    });

    request.write(payload);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    print('Edge Function HTTP Status: ${response.statusCode}');
    print('Edge Function Response: $responseBody');
  } catch (e) {
    print('HTTP Request Error: $e');
  }

  exit(0);
}
