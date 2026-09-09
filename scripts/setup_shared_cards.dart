import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('🔍 Checking shared_cards table on Supabase...');
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? serviceKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1].trim();
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceKey = line.split('=')[1].trim();
  }

  if (url == null || serviceKey == null) {
    print('❌ Missing Supabase credentials in .env');
    exit(1);
  }

  final client = SupabaseClient(url, serviceKey);

  try {
    // Test selecting from shared_cards table
    final res = await client.from('shared_cards').select().limit(1);
    print('✅ Table public.shared_cards exists! Rows: $res');
  } catch (e) {
    print('⚠️ shared_cards table query result / error: $e');
  }
  exit(0);
}
