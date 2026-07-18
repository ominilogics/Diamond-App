import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final url = 'https://jlfgigvfmxuvlixohzli.supabase.co';
  final serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsZmdpZ3ZmbXh1dmxpeG9oemxpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjM0NTMzMCwiZXhwIjoyMDk3OTIxMzMwfQ.HIJd0uoxUXaRfPCWP0NNmWOAk0njM-8ZfzTC3k60Md0';

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
