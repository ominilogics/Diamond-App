import 'package:supabase/supabase.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  final url = 'https://jlfgigvfmxuvlixohzli.supabase.co';
  final anonKey = 'sb_publishable_MJdCHQEtNID8KIEPnstRkw_8-7iqxKG';
  final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsZmdpZ3ZmbXh1dmxpeG9oemxpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjM0NTMzMCwiZXhwIjoyMDk3OTIxMzMwfQ.HIJd0uoxUXaRfPCWP0NNmWOAk0njM-8ZfzTC3k60Md0';

  // Use anon client for standard function calls
  final anonClient = SupabaseClient(url, anonKey);
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
