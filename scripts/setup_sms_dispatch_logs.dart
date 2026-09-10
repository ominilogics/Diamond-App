import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final url = 'https://jlfgigvfmxuvlixohzli.supabase.co';
  final serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsZmdpZ3ZmbXh1dmxpeG9oemxpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjM0NTMzMCwiZXhwIjoyMDk3OTIxMzMwfQ.HIJd0uoxUXaRfPCWP0NNmWOAk0njM-8ZfzTC3k60Md0';

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
