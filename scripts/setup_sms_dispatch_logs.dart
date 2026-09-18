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

  print('Checking public.sms_dispatch_logs table...');
  try {
    final response = await client.from('sms_dispatch_logs').select().limit(1);
    print('SUCCESS: public.sms_dispatch_logs table exists and is accessible!');
  } catch (e) {
    print('Table check output: $e');
  }
  exit(0);
}
