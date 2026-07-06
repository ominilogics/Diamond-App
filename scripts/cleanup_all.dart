import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('🧹 Performing total wipe of database AND storage bucket...');
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? serviceKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceKey = line.split('=')[1];
  }
  
  final client = SupabaseClient(url!, serviceKey!);
  
  // Wipe DB
  print('-> Wiping cards and categories tables...');
  await client.from('cards').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  await client.from('categories').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  
  // Wipe Storage
  print('-> Wiping all old files in storage bucket...');
  final objects = await client.storage.from('card_assets').list(path: 'backgrounds');
  if (objects.isNotEmpty) {
    final paths = objects.where((e) => e.name != '.emptyFolderPlaceholder').map((e) => 'backgrounds/${e.name}').toList();
    if (paths.isNotEmpty) {
      await client.storage.from('card_assets').remove(paths);
    }
    print('🗑️ Deleted ${paths.length} ghost files from storage.');
  }
  
  print('✅ Total wipe complete! The slate is 100% clean.');
  exit(0);
}
