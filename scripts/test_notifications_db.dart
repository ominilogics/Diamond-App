import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? serviceKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1].trim();
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceKey = line.split('=')[1].trim();
  }

  if (url == null || serviceKey == null) {
    print('Error: Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env');
    exit(1);
  }

  final client = SupabaseClient(url, serviceKey);

  try {
    print('1. Checking user_fcm_tokens...');
    final tokens = await client.from('user_fcm_tokens').select();
    print('Found ${tokens.length} FCM tokens.');

    print('2. Checking notifications table...');
    final notifs = await client.from('notifications').select();
    print('Found ${notifs.length} total notifications across all users.');

    if (notifs.isNotEmpty) {
      print('Sample notification: ${notifs.last}');
    }

  } catch (e) {
    print('Error: $e');
  }
}
