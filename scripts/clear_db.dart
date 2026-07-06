import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('🧹 Clearing database...');
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? serviceKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceKey = line.split('=')[1];
  }
  
  final client = SupabaseClient(url!, serviceKey!);
  
  await client.from('cards').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  await client.from('categories').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  print('✅ Database cleared!');
  exit(0);
}
